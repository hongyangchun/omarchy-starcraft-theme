# 游戏/影视 IP 主题流水线（区别于名画公有领域流水线）

名画主题（vangogh/monet/ukiyo）走 Wikimedia Commons 公有领域扫描画；游戏/影视
IP 主题（black-myth-wukong / ghost-of-tsushima / cyberpunk-2077 /
no-rest-for-the-wicked / starcraft）没有公有领域原画，壁纸来源完全不同。

## 先问清需求方向（v1 返工 4 轮的教训）

「做个 X 主题」有两种完全相反的解读，动手前必须确认：
- **官方素材路线**：直接收集该 IP 的官方重制版/宣传原画/高清截图（用户在
  StarCraft 主题上最终要的是这个——"官方 Remastered 原画"，AI 生成的
  "风格致敬"被明确否决："我要的是星际争霸重制版的高清壁纸"）
- **原创风格致敬路线**：AI 生成"XX 风格"场景（规避版权，不出现具体
  单位/Logo/角色）——只在用户明说"怕版权/要原创"时采用

同一句「星际争霸1主题」，两条路线产出完全不同的东西。猜错方向 = 多轮返工。

## 官方素材路线（v4-v6 验证）

- 来源：wallhaven.cc API 免费无 key，`q=<ip名>&categories=100&purity=100&sorting=favorites&atleast=2560x1440`
  按收藏数排序拉 3 页；社区收藏榜头部基本是该 IP 官方重制原画的高清传播版
- **必须逐张 vision 目检**：搜索结果混有大量动漫 crossover、其他游戏
  （Halo 光环风）、纯 logo、真人 cos——标签不可信，一 indicative 例子：
  "starcraft" 搜索里混进了金发少女骑兽图和多族跨界大乱斗图
- 裁切规整：`magick in.jpg -resize 3840x3840 -gravity center -crop 16:9 +repage -quality 90 out.jpg`
- 素材许可：README 标注 "Artwork © <厂商> — unofficial fan-theme
  distribution"（wukong 主题先例）；代码部分 MIT 不变
- 优势：分辨率原生（最高 7203×3060）、官方原画质感、用户零调教成本
- AI 生图路线的硬伤（实测）：pollinations 免费档锁死 1024×576（所有
  width/height/model 参数被钳制），插值放大必糊——被用户"质量太差"否决

## 主题 repo 的坑（都会咬人）

- **`omarchy-refresh-shell` 会把 bar.layout 重置为出厂默认**——所有第三方
  widget 位置全丢，且锁屏状态下它拒绝重启 shell。恢复：找最新的
  `shell.json.bak.<epoch>`（插件 enable/install 时自动生成），cp 回去后
  再 `omarchy plugin enable <id>` 补位置。**不要用 refresh-shell 来"应用"
  插件**——enable 本身已热加载
- **`git reset --hard origin/main` 不删 untracked 文件**：themes 目录里
  v4 时代的旧图若不在 git 索引里，reset 后依然残留——换壁纸集时用
  rsync --delete 或手动 rm，别只 reset
- 壁纸快照机制：`omarchy theme bg next` 只读
  `~/.local/state/omarchy/current/theme/backgrounds/` + 用户层
  `~/.config/omarchy/backgrounds/<name>/`，从不读 `themes/<name>/backgrounds/`。
  推新壁纸后要么 cp 到两处，要么重跑 `omarchy theme set <name>` 重建快照
- 锁屏状态下 `omarchy theme set` / shell 重启被拒——改完配置必须
  `omarchy-theme-bg-set <壁纸绝对路径>` 手动推送显示层，否则桌面仍显示
  旧图（state 链接已更新但显示进程没刷新）
- agent 会话里 `grim` 截屏常因 Wayland 会话隔离失败（-o 参数歧义也报错），
  正确语法是 `grim /tmp/out.jpg`；截屏验证桌面壁纸是唯一可靠手段，
  用户"还是旧图"的反馈往往对应 state 已更新但显示未刷新

## v6 定稿的审美结论（StarCraft 主题）

用户两轮反馈沉淀的偏好：**深色背景 + 单主体特写 + 冷色调**；排斥明亮
大乱战群像、高饱和彩色爆发。玩家对此类主题的验收标准是"是不是官方
Remastered 那种感觉"——AI 风格致敬图即使构图好也会因"不是官方原画"
被否。官方图单张文件 1-3MB（细节密度）是正常水位，400KB 的插值放大图
会被一眼识破。
