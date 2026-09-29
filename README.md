# WeChatMulti-macOS
一个适用于 macOS 的轻量级 WeChat 双开/多开脚本工具，支持 微信 4.x 及以上版本，帮助用户在 Mac 上同时登录多个微信账号。通过简单的 shell 脚本，你可以一键实现 微信双开，批量创建多个独立的 WeChat 副本，支持自动修改 Bundle ID、重新签名，并提供 自动重建副本 功能，解决每次微信更新后的重复操作问题。无论你是需要 个人微信与工作微信分开使用，还是想要测试 多个账号同时运行，本项目都能为你提供高效的 macOS 微信多开解决方案。



### 简介（英文版）

**WeChatMulti-macOS**
 A lightweight shell script for macOS that allows you to run multiple instances of WeChat (dual or more).
 It supports WeChat **v4.x+** and above, works with the latest macOS versions, and provides:

- 🚀 One-click dual launch (`auto` mode)
- 📦 Multi-instance support (`multi N` mode)
- 🔄 Auto rebuild after WeChat update (`rebuild` mode)
- 🛠 Simple manual clone instructions included

⚠️ Disclaimer: This project is for **educational and research purposes only**. Use at your own risk.

------

### 简介（中文版）

**WeChatMulti-macOS**
 这是一个轻量级的 **macOS 微信双开/多开工具脚本**，支持 **WeChat 4.x 及以上版本**。

功能特点：

- 🚀 一键双开（`auto` 模式）
- 📦 多开支持，可创建多个副本（`multi N` 模式）
- 🔄 微信更新后自动重建副本（`rebuild` 模式）
- 🛠 同时提供手动操作教程，简单易懂

⚠️ **免责声明**：本项目仅供学习与研究使用，请自行评估风险。

------



# macOS 双开/多开微信完整使用教程（支持 4.X 及以上版本）


---

## 一、准备工作
1. 确保系统为 **macOS**，并已正确安装官方微信（路径：`/Applications/WeChat.app`）。
2. 确认系统中具备以下工具：
   - `ditto`
   - `codesign`
   - `xattr`
   - `/usr/libexec/PlistBuddy`
3. 打开终端（Terminal），确保拥有 `sudo` 权限。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/376ef533a0f8424fb372c36f5e1f0491.png)



---

## 二、一键双开脚本（推荐方法）

 
> ⚠️ **免责声明**
> 本教程及脚本仅供学习和研究使用，方法来源于网络。请自行评估风险与适用性。若因操作导致系统异常、微信账号异常或其他损失，均由使用者本人承担，与本文作者无关。

> 更多详情请阅读 [DISCLAIMER.md](./DISCLAIMER.md)

 
---

### 终端操作｜创建脚本文件

我们需要先新建一个脚本文件，把前面给出的 `wechat-2.sh` 代码保存进去。

### 1. 新建文件

在终端中输入：

```bash
cd ~
touch wechat-2.sh
```

这样就在用户主目录下新建了一个 `wechat-2.sh` 文件。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e754b6baf5b34af2b7ee0fe24c79f46d.png)


---

### 2. 打开文件进行编辑

你可以用以下几种方法打开文件：




#### 方法1：用文本编辑器（推荐）

如果你习惯图形界面，可以用系统自带的 **TextEdit**：

```bash
open -e wechat-2.sh
```

把脚本粘贴进去，然后保存即可。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0bb415a392754d868bdf7798c5d73bc8.png)

#### 方法2：用 VS Code（如果已安装）

```bash
code wechat-2.sh
```
#### 方法3：用终端内置编辑器 nano

```bash
nano wechat-2.sh
```

* 复制我提供的脚本内容，粘贴进去；
* 粘贴完成后，按下 `Ctrl + O` 保存，然后回车；
* 按 `Ctrl + X` 退出。
---

### 3. 赋予执行权限

保存文件后，需要让脚本有运行权限：

```bash
chmod +x wechat-2.sh
```

这样 `wechat-2.sh` 就变成了可执行文件。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2fad88233506407db29e3cb40d9c826f.png)

---

### 4. 运行脚本

* **第一次运行（自动复制+双开）**

  ```bash
  sudo ./wechat-2.sh auto --force
  ```

  系统会提示输入管理员密码，请输入你的 Mac 密码（输入时不会显示）。
  
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f153482e3931453da4a9bfbbb82f3536.png)


* **多开运行（生成多个小绿书副本）**

  ```bash
  sudo ./wechat-2.sh multi 3 --force
  ```

  会自动生成：小绿书1、小绿书2、小绿书3。
  
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7f3b1752a2b04fc2819ed4c24ec74cf2.png)


* **更新后重建副本**

  ```bash
  sudo ./wechat-2.sh rebuild --force
  ```

* **关闭所有微信进程**

  ```bash
  sudo ./wechat-2.sh kill
  ```

---

👉 总结一下操作步骤：

1. `touch wechat-2.sh` 新建文件
2. `nano wechat-2.sh` 或 `open -e wechat-2.sh` 编辑脚本
3. `chmod +x wechat-2.sh` 添加运行权限
4. `sudo ./wechat-2.sh auto --force` 执行

 

 

---

## 三、完整脚本（支持双开、多开、更新后重建）

> 以下脚本包含 **multi 多开** 与 **rebuild 重建副本** 功能。

```bash
#!/bin/bash
# macOS WeChat Multi Instance Script
# Usage:
#   sudo ./wechat-2.sh auto --force
#   sudo ./wechat-2.sh multi 3 --force   # 多开3个副本
#   sudo ./wechat-2.sh rebuild --force   # 更新后自动重建所有副本（数据自动恢复）
#   ./wechat-2.sh status                 # 查看副本/BundleID/数据映射
#   ./wechat-2.sh orphans                # 查看有数据、却没有副本在用的容器
#   sudo ./wechat-2.sh setup --id com.tencent.xinWeChat.dual.1553
#                                        # 强制把副本接回指定数据容器
#
# 数据恢复原理：副本的 Bundle ID 记录在其 Info.plist 里；rebuild 时先读旧 ID
# 再原样写回，App 自动读取 ~/Library/Containers 下的原有聊天数据。全新副本
# 分配随机但未占用的 ID。
#
# 安全约束（防止聊天记录与副本断开）：
#   - App 存在但读不到合法的 dual ID -> 直接中止，绝不静默换 ID
#   - 需要新建副本时若发现「有数据但没人用」的容器 -> 列出让用户选择沿用
#   - 只有确认无旧数据可用（或显式 --id）时，才分配全新随机 ID

set -euo pipefail

# 颜色
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# 默认路径
WECHAT_APP="/Applications/WeChat.app"
DEST_DIR="/Applications"
BASE_APP_NAME="小绿书"
FORCE=0
FORCE_ID=""      # --id：强制使用该 Bundle ID（把副本接回某个已有数据容器）

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

# 当前用户的 Containers 目录（sudo 下取 SUDO_USER 的家目录）
containers_dir() {
    echo "$([ -n "${SUDO_USER:-}" ] && eval echo "~$SUDO_USER" || echo "$HOME")/Library/Containers"
}

# 读取副本当前 Bundle ID（删除重建前调用，用于保持 ID 不变）
current_bundle_id() {
    /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$DEST_DIR/$1/Contents/Info.plist" 2>/dev/null || true
}

# 该 ID 是否已被某个副本使用
is_id_used() {
    local id="$1" app
    for app in $(list_existing_apps); do
        [ "$(current_bundle_id "$app")" = "$id" ] && return 0
    done
    return 1
}

# 容器里是否有真实数据（登录过账号才算，刚初始化的空壳容器不算）
container_has_data() {
    local cdir="$1" f
    for f in "$cdir/Data/Documents/xwechat_files"/wxid_*; do
        [ -e "$f" ] && return 0
    done
    [ -d "$cdir/Data/Documents/app_data/db_storage" ] && return 0
    return 1
}

# 有数据、却没有被任何副本使用的容器（格式：BundleID|大小）
list_orphan_containers() {
    local cdir dir id
    cdir=$(containers_dir)
    for dir in "$cdir"/com.tencent.xinWeChat.dual.*; do
        [ -d "$dir" ] || continue
        id=$(basename "$dir")
        container_has_data "$dir" || continue
        is_id_used "$id" && continue
        printf '%s|%s\n' "$id" "$(du -sh "$dir" 2>/dev/null | cut -f1)"
    done
}

# 查看无主容器（有数据但没人在用）
show_orphans() {
    local orphans id size
    orphans=$(list_orphan_containers)
    if [ -z "$orphans" ]; then
        echo -e "${GREEN}✓ 没有无主容器：所有有数据的容器都已被某个副本使用${NC}"
        return
    fi
    echo -e "${YELLOW}以下容器有聊天数据，但没有任何副本在使用：${NC}"
    while IFS='|' read -r id size; do
        printf "  %-40s %s\n" "$id" "$size"
    done <<< "$orphans"
    echo -e "${YELLOW}若这些数据属于某个副本，可用 --id 让副本重新接上它：${NC}"
    echo -e "${YELLOW}  sudo $0 setup --id <上面列出的 Bundle ID>${NC}"
}

# 校验 Bundle ID 合法且不与其它副本冲突
validate_bundle_id() {
    local id="$1" app_name="$2" app other
    if [[ "$id" != com.tencent.xinWeChat.dual.* ]]; then
        echo -e "${RED}错误：Bundle ID 必须以 com.tencent.xinWeChat.dual. 开头（当前：${id}）${NC}" >&2
        return 1
    fi
    for app in $(list_existing_apps); do
        [ "$app" = "$app_name" ] && continue
        other=$(current_bundle_id "$app")
        if [ "$other" = "$id" ]; then
            echo -e "${RED}错误：$id 已被 $app 使用，两个副本共用同一 ID 会互相覆盖数据${NC}" >&2
            return 1
        fi
    done
    return 0
}

# 新建副本时决定用哪个 ID：先让用户从无主容器里挑，避免"一分配新 ID，老数据就失联"
pick_bundle_id_for_new_app() {
    local app_name=$1 orphans id size choice i
    local -a ids=()
    local -a sizes=()

    orphans=$(list_orphan_containers)
    if [ -z "$orphans" ]; then
        new_bundle_id
        return 0
    fi

    while IFS='|' read -r id size; do
        [ -n "$id" ] || continue
        ids+=("$id"); sizes+=("$size")
    done <<< "$orphans"

    if [ ! -t 0 ]; then
        {
            echo -e "${RED}错误：检测到有数据的无主容器，但当前不是交互终端，无法询问。${NC}"
            echo -e "${YELLOW}请用 --id 明确指定要沿用的容器，或先运行 $0 orphans 查看${NC}"
            for i in "${!ids[@]}"; do echo "  --id ${ids[$i]}   (${sizes[$i]})"; done
        } >&2
        return 1
    fi

    {
        echo ""
        echo -e "${YELLOW}⚠️  以下容器里有聊天数据，但当前没有任何副本在使用：${NC}"
        for i in "${!ids[@]}"; do
            printf "  %d) %-40s %s\n" "$((i+1))" "${ids[$i]}" "${sizes[$i]}"
        done
        printf "   0) 都不沿用，分配全新 Bundle ID（新容器，需要重新登录）\n"
        printf "请选择要沿用的容器 [0-%d，回车=0]: " "${#ids[@]}"
    } >&2

    if ! read -r choice; then
        echo -e "${RED}没有读到选择（输入被关闭），为安全起见已中止${NC}" >&2
        return 1
    fi
    case "${choice:-0}" in
        ""|0|n|N) new_bundle_id; return 0 ;;
    esac
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#ids[@]}" ]; then
        echo "${ids[$((choice-1))]}"
        return 0
    fi
    echo -e "${RED}无效选择，已中止${NC}" >&2
    return 1
}

# 副本已存在、沿用其记录的 ID 时调用：
# 若该 ID 的容器里并没有聊天数据，而磁盘上存在"有数据却没人在用"的容器，
# 说明当前 ID 很可能不是它真正的数据（例如之前被旧版脚本换过 ID），提示接回。
# 返回选中接回的 ID（stdout），不接回/无法询问时返回空。
maybe_offer_rebind() {
    local app_name=$1 cur_id=$2 cdir orphans id size i choice
    local -a ids=()
    local -a sizes=()

    cdir=$(containers_dir)
    container_has_data "$cdir/$cur_id" && return 0     # 当前容器有数据，无需提示
    orphans=$(list_orphan_containers)
    [ -n "$orphans" ] || return 0

    while IFS='|' read -r id size; do
        [ -n "$id" ] || continue
        ids+=("$id"); sizes+=("$size")
    done <<< "$orphans"

    {
        echo ""
        echo -e "${YELLOW}⚠️  $app_name 目前用的容器（${cur_id}）里没有聊天数据，但下列容器有数据且没有被任何副本使用：${NC}"
        for i in "${!ids[@]}"; do
            printf "  %d) %-40s %s
" "$((i+1))" "${ids[$i]}" "${sizes[$i]}"
        done
        printf "   0) 不接回，继续用 %s\n" "$cur_id"
    } >&2

    if [ ! -t 0 ]; then
        {
            echo -e "${YELLOW}  当前不是交互终端，已保持原 ID。如需接回，请显式指定：${NC}"
            echo -e "${YELLOW}    sudo $0 setup --force --id ${ids[0]}${NC}"
        } >&2
        return 0
    fi

    printf "是否把 %s 接回其中某个容器? [0-%d，回车=0]: " "$app_name" "${#ids[@]}" >&2
    if ! read -r choice; then
        echo -e "${YELLOW}  未读到选择，保持原 ID${NC}" >&2
        return 0
    fi
    case "${choice:-0}" in
        ""|0|n|N) return 0 ;;
    esac
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#ids[@]}" ]; then
        echo "${ids[$((choice-1))]}"
        return 0
    fi
    echo -e "${YELLOW}  无效选择，保持原 ID${NC}" >&2
    return 0
}

# 为新副本分配随机且未被占用的 Bundle ID（不与现有容器/副本冲突）
new_bundle_id() {
    local id cdir tries=0 app occupied
    cdir=$(containers_dir)
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

# 重建副本的统一流程：
#   已有副本 -> 沿用原 ID（数据自动恢复），读不到合法 ID 就中止
#   全新副本 -> 沿用用户从无主容器里选中的 ID，或分配全新 ID
recreate_app() {
    local app_name=$1 old_id

    if [ -d "$DEST_DIR/$app_name" ]; then
        old_id=$(current_bundle_id "$app_name")
        if [ -z "$old_id" ] || [[ "$old_id" != com.tencent.xinWeChat.dual.* ]]; then
            {
                echo -e "${RED}错误：$app_name 已存在，但读不到合法的 dual Bundle ID（当前读到：'${old_id:-空}'）。${NC}"
                echo -e "${RED}  若继续重建，它的数据容器会变成无主容器，聊天记录将与副本断开。${NC}"
                echo -e "${YELLOW}  请先用 $0 orphans 找到它对应的容器，再用 --id 明确指定：${NC}"
                echo -e "${YELLOW}    sudo $0 rebuild --id com.tencent.xinWeChat.dual.<N>${NC}"
            } >&2
            exit 1
        fi
        if [ -n "$FORCE_ID" ]; then
            echo -e "${YELLOW}  --id 覆盖 App 内记录的 $old_id -> $FORCE_ID${NC}"
            old_id="$FORCE_ID"
        else
            echo -e "${BLUE}  沿用原 Bundle ID: $old_id${NC}"
            local rebind
            rebind=$(maybe_offer_rebind "$app_name" "$old_id") || exit 1
            if [ -n "$rebind" ]; then
                echo -e "${YELLOW}  改为接回: $rebind${NC}"
                old_id="$rebind"
            fi
        fi
    elif [ -n "$FORCE_ID" ]; then
        old_id="$FORCE_ID"
        echo -e "${BLUE}  使用 --id 指定的 Bundle ID: $old_id${NC}"
    else
        old_id=$(pick_bundle_id_for_new_app "$app_name") || exit 1
        if [ -z "$old_id" ]; then
            echo -e "${RED}未能确定 Bundle ID，已中止${NC}" >&2
            exit 1
        fi
        echo -e "${BLUE}  分配 Bundle ID: $old_id${NC}"
    fi

    validate_bundle_id "$old_id" "$app_name" || exit 1

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

    local orphans
    orphans=$(list_orphan_containers)
    if [ -n "$orphans" ]; then
        echo ""
        echo -e "${YELLOW}另有容器有数据但没有副本在使用（可用 --id 让副本接回）：${NC}"
        while IFS='|' read -r id _; do
            printf "  %-40s\n" "$id"
        done <<< "$orphans"
    fi
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
            if [ -n "$FORCE_ID" ]; then
                echo -e "${RED}错误：multi 会创建多个副本，不能共用同一个 --id${NC}" >&2
                exit 1
            fi
            for i in $(seq 1 "$count"); do
                recreate_app "${BASE_APP_NAME}${i}.app"
            done
            start_apps $(for i in $(seq 1 "$count"); do echo "${BASE_APP_NAME}${i}.app"; done)
            ;;
        rebuild)
            check_wechat
            echo -e "${BLUE}检测到系统更新或微信更新，正在重建副本（沿用原 Bundle ID，数据自动保留）...${NC}"
            local apps=$(list_existing_apps)
            local app_count=0 a
            for a in $apps; do app_count=$((app_count+1)); done
            if [ -n "$FORCE_ID" ] && [ "$app_count" -gt 1 ]; then
                echo -e "${RED}错误：有 $app_count 个副本，--id 只能用于单个副本的重建${NC}" >&2
                exit 1
            fi
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
        orphans)
            show_orphans
            ;;
        -k|kill)
            kill_wechat
            ;;
        -h|--help|"")
            echo "用法: $0 {setup|start|auto|multi N|rebuild|status|orphans|kill} [--force] [--id <Bundle ID>]"
            echo "  setup   创建单个小绿书副本"
            echo "  multi N 创建N个副本（小绿书1 ~ 小绿书N）"
            echo "  rebuild 微信升级后重建所有副本（Bundle ID 自动复用，数据不丢）"
            echo "  status  查看副本/Bundle ID/数据容器映射"
            echo "  orphans 查看有数据、却没有副本在用的无主容器"
            echo "  kill    只关闭小绿书副本（不影响原生微信）"
            echo "  --id    强制使用指定 Bundle ID，把副本接回某个已有数据容器"
            echo "          例：sudo $0 setup --id com.tencent.xinWeChat.dual.1553"
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            exit 1
            ;;
    esac
}

# 参数解析：--force / --id 是选项，其余按顺序传给 main
POSITIONAL=()
while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=1; shift ;;
        --id)
            FORCE_ID="${2:-}"
            if [ -z "$FORCE_ID" ]; then
                echo -e "${RED}--id 后面需要一个 Bundle ID${NC}"
                exit 1
            fi
            shift 2
            ;;
        --id=*) FORCE_ID="${1#--id=}"; shift ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

main ${POSITIONAL[@]+"${POSITIONAL[@]}"}
```

---

## 四、手动操作流程（可选）

  如果你只想多开 1 次，可以手动操作：

1. **复制应用**

   ```bash
   sudo cp -R /Applications/WeChat.app /Applications/小绿书.app
   ```

2. **修改应用唯一标识符**

   ```bash
   sudo /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier net.maclub.wechat" /Applications/小绿书.app/Contents/Info.plist
   ```

3. **重新签名应用**

   ```bash
   sudo codesign --force --deep --sign - /Applications/小绿书.app
   ```

4. **验证结果**
    打开 Finder > 应用程序，若能看到 `小绿书.app`（图标可能灰色或正常），即可双开。

------

 

## 五、多开操作（创建多个副本）

```bash
# 创建3个副本：小绿书1、小绿书2、小绿书3
sudo ./wechat-2.sh multi 3 --force
```

---

## 六、更新后自动重建副本

### 为什么需要重建？

* 微信每次更新后，`/Applications/WeChat.app` 会被覆盖；
* 之前生成的副本可能失效或无法正常启动；
* 使用 `rebuild` 模式，可以**自动检测所有小绿书副本并重新克隆**。

### 使用方法

```bash
# 一键重建已存在的所有副本
sudo ./wechat-2.sh rebuild --force
```

### 效果

* 脚本会自动找到 `/Applications/` 下所有 `小绿书N.app`；
* 删除旧副本并重新复制新版微信；
* **沿用原来的 Bundle ID** 并重新签名，聊天记录和登录态自动恢复；
* 保持原来的命名（小绿书1、小绿书2…）。

### 聊天数据放在哪里？

* 每个副本的聊天数据按 **Bundle ID** 存放在 `~/Library/Containers/com.tencent.xinWeChat.dual.<N>/`；
* Bundle ID 记录在副本的 `Info.plist` 里，`rebuild` 先读出来再原样写回，所以数据不会丢；
* 如果某个容器有数据，却没有任何副本在引用它（例如副本被删除后重建过），脚本会把它识别为**无主容器**。

```bash
# 查看无主容器（有数据但没有副本在用）
./wechat-2.sh orphans

# 让副本重新接回指定容器，聊天记录与登录态都会回来
sudo ./wechat-2.sh setup --id com.tencent.xinWeChat.dual.1553
```

### 安全约束（避免聊天记录与副本断开）

* 副本已存在却读不到合法的 Bundle ID 时，脚本**直接中止**，绝不静默分配新 ID；
* 新建副本时若发现无主容器，会先列出来让你选择沿用哪个，回车则创建全新容器；
* `--id` 只作用于单个副本，`multi` 与多副本 `rebuild` 不允许使用；
* 沿用原 ID 时，如果该副本的容器里**没有聊天数据**、而磁盘上存在有数据的无主容器，脚本会先提示你选择是否接回（非交互环境下只提示并保持原 ID）。

---

## 七、总结

* **双开**：适合 2 个账号同时使用；
* **多开**：通过 `multi` 参数创建多个副本，实现无限多开；
* **更新后重建**：使用 `rebuild` 一键重建所有副本，免去升级后的手动操作。

---

 
