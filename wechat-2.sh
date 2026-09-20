#!/bin/bash
# macOS WeChat Multi Instance Script
# Usage:
#   sudo ./wechat-2.sh auto --force
#   sudo ./wechat-2.sh multi 3 --force   # 多开3个副本
#   sudo ./wechat-2.sh rebuild --force   # 更新后自动重建所有副本（数据自动恢复）
#   ./wechat-2.sh status                 # 查看副本/BundleID/数据映射
#
# 数据恢复原理：副本的 Bundle ID 记录在其 Info.plist 里；rebuild 时先读旧 ID
# 再原样写回，App 自动读取 ~/Library/Containers 下的原有聊天数据。全新副本
# 分配随机但未占用的 ID。

set -euo pipefail

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# 默认路径
WECHAT_APP="/Applications/WeChat.app"
DEST_DIR="/Applications"
BASE_APP_NAME="小绿书"
FORCE=0

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || { echo -e "${RED}缺少命令: $1${NC}"; exit 1; }
}
for cmd in ditto codesign xattr /usr/libexec/PlistBuddy; do require_cmd "$cmd"; done

check_wechat() {
    if [ ! -d "$WECHAT_APP" ]; then
        echo -e "${RED}未找到微信: $WECHAT_APP${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ 检测到微信已安装${NC}"
}

remove_app() {
    local dest="$DEST_DIR/$1"
    if [ -d "$dest" ]; then
        if [ $FORCE -eq 1 ]; then
            sudo rm -rf "$dest"
        else
            read -p "是否删除并重新创建 $1? (y/n): " yn
            [[ $yn =~ ^[Yy]$ ]] && sudo rm -rf "$dest"
        fi
    fi
}

copy_wechat() {
    local app_name=$1
    sudo ditto "$WECHAT_APP" "$DEST_DIR/$app_name"
}

# ============ Bundle ID 分配与保留（无状态文件） ============
# 微信沙盒数据按 Bundle ID 存放在 ~/Library/Containers/com.tencent.xinWeChat.dual.<N>
# 规则：
#   重建已有副本 -> 先读旧 App 的 Bundle ID，重建后原样写回，数据自动恢复
#   全新副本     -> 分配随机但未被占用的新 ID
# 也就是说：ID 记录在 App 的 Info.plist 里，随 App 走，不依赖任何外部状态。

# 读取副本当前 Bundle ID（删除重建前调用，用于保持 ID 不变）
current_bundle_id() {
    /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$DEST_DIR/$1/Contents/Info.plist" 2>/dev/null || true
}

# 为新副本分配随机且未被占用的 Bundle ID（不与现有容器/副本冲突）
new_bundle_id() {
    local id cdir tries=0 app occupied
    cdir="$([ -n "${SUDO_USER:-}" ] && eval echo "~$SUDO_USER" || echo "$HOME")/Library/Containers"
    while [ $tries -lt 100 ]; do
        tries=$((tries+1))
        id="com.tencent.xinWeChat.dual.$RANDOM"
        [ -d "$cdir/$id" ] && continue
        occupied=0
        for app in $(list_existing_apps); do
            if [ "$(current_bundle_id "$app")" = "$id" ]; then occupied=1; break; fi
        done
        if [ $occupied -eq 0 ]; then echo "$id"; return; fi
    done
    echo "com.tencent.xinWeChat.dual.$$"   # 兜底：用进程号保证唯一
}

modify_bundle_id() {
    local app_name=$1 new_id=${2:-}
    local info_plist="$DEST_DIR/$app_name/Contents/Info.plist"
    if [ -z "$new_id" ]; then
        new_id=$(new_bundle_id "$app_name")
    fi
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $new_id" "$info_plist"
    sudo /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $app_name" "$info_plist" || true
    echo -e "${GREEN}  $app_name Bundle ID = $new_id${NC}"
}

# 重建副本的统一流程：已有副本沿用原 ID（数据自动恢复），全新副本分配新 ID
recreate_app() {
    local app_name=$1 old_id
    old_id=$(current_bundle_id "$app_name")
    if [ -n "$old_id" ] && [[ "$old_id" == com.tencent.xinWeChat.dual.* ]]; then
        echo -e "${BLUE}  沿用原 Bundle ID: $old_id${NC}"
    else
        old_id=""
    fi
    remove_app "$app_name"
    copy_wechat "$app_name"
    modify_bundle_id "$app_name" "$old_id"
    resign_app "$app_name"
}

resign_app() {
    local app_name=$1
    local dest="$DEST_DIR/$app_name"
    sudo rm -rf "$dest/Contents/_CodeSignature" || true
    sudo xattr -dr com.apple.quarantine "$dest" || true
    # 注意：微信 4.1.15+ 使用 --deep 签名会报 "cannot find code object" 且留下
    # WeChat.cstemp 竞态导致封印失效；改为只签外层，嵌套组件保留腾讯原签名
    sudo codesign --force --sign - --timestamp=none "$dest"
}

start_apps() {
    for app_name in "$@"; do open -n "$DEST_DIR/$app_name"; sleep 1; done
}

# 只杀小绿书副本，绝不动原生 WeChat.app（曾用 pkill -f "WeChat" 会误杀原生微信）
kill_wechat() {
    local app_name
    for app_name in $(list_existing_apps); do
        pkill -f "$DEST_DIR/$app_name" 2>/dev/null || true
    done
}

# 查找已存在的小绿书副本
list_existing_apps() {
    ls "$DEST_DIR" | grep "^$BASE_APP_NAME[0-9]*\.app$" || true
}

# 查看副本 <-> Bundle ID <-> 数据容器 的映射关系（无状态，实时读取）
show_status() {
    local apps app id c
    apps=$(list_existing_apps)
    if [ -z "$apps" ]; then
        echo "未找到任何副本（$DEST_DIR/$BASE_APP_NAME*.app），先运行 setup/auto/multi"
        return
    fi
    local home_dir="$([ -n "${SUDO_USER:-}" ] && eval echo "~$SUDO_USER" || echo "$HOME")"
    echo -e "${BLUE}副本状态：${NC}"
    for app in $apps; do
        id=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$DEST_DIR/$app/Contents/Info.plist" 2>/dev/null || echo "?")
        c="$home_dir/Library/Containers/$id"
        printf "  %-16s ID=%-44s " "$app" "$id"
        if [ -d "$c/Data/Documents" ]; then
            printf "数据:%s\n" "$(du -sh "$c/Data" 2>/dev/null | cut -f1)"
        else
            printf "数据:无\n"
        fi
    done
}

main() {
    case "${1:-}" in
        setup)
            check_wechat
            recreate_app "${BASE_APP_NAME}.app"
            ;;
        start)
            start_apps "WeChat.app" "${BASE_APP_NAME}.app"
            ;;
        auto)
            check_wechat
            recreate_app "${BASE_APP_NAME}.app"
            start_apps "WeChat.app" "${BASE_APP_NAME}.app"
            ;;
        multi)
            local count=${2:-2}
            check_wechat
            for i in $(seq 1 "$count"); do
                recreate_app "${BASE_APP_NAME}${i}.app"
            done
            start_apps $(for i in $(seq 1 "$count"); do echo "${BASE_APP_NAME}${i}.app"; done)
            ;;
        rebuild)
            check_wechat
            echo -e "${BLUE}检测到系统更新或微信更新，正在重建副本（沿用原 Bundle ID，数据自动保留）...${NC}"
            local apps=$(list_existing_apps)
            for app_name in $apps; do
                echo -e "${YELLOW}重建 $app_name ...${NC}"
                recreate_app "$app_name"
            done
            echo -e "${GREEN}✓ 所有副本已重新生成，聊天记录与登录态自动恢复${NC}"
            show_status
            echo -e "${YELLOW}提示：若要彻底重置某副本（登录全新账号），需连同数据容器一起删除，再重新创建才会分配全新 ID：${NC}"
            echo -e "${YELLOW}  rm -rf ~/Library/Containers/<上表中该副本的 Bundle ID>${NC}"
            ;;
        status)
            show_status
            ;;
        -k|kill)
            kill_wechat
            ;;
        -h|--help|"")
            echo "用法: $0 {setup|start|auto|multi N|rebuild|status|kill} [--force]"
            echo "  setup   创建单个小绿书副本"
            echo "  multi N 创建N个副本（小绿书1 ~ 小绿书N）"
            echo "  rebuild 微信升级后重建所有副本（Bundle ID 自动复用，数据不丢）"
            echo "  status  查看副本/Bundle ID/数据容器映射"
            echo "  kill    只关闭小绿书副本（不影响原生微信）"
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            exit 1
            ;;
    esac
}

for arg in "$@"; do [[ $arg == "--force" ]] && FORCE=1; done
main "$@"
