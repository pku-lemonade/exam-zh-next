# exam-zh for Typst

Chinese exam papers in Typst, following the design of the LaTeX class
[exam-zh](https://github.com/xkwxdyy/exam-zh): choice options that pick their
own column count, answer parentheses and fill-in blanks, solutions with
scoring points, seal lines, A3 two-up papers, and student and teacher
versions from one source.

# exam-zh：Typst 中国试卷模板

本模板用 Typst 重新实现了 LaTeX 试卷模板 exam-zh 的全部常用功能：

- 选择题选项按内容宽度自动排成 4、2 或 1 列，同一行选项基线对齐；
- 括号 `paren` 自动排到行末，放不下时排到下一行行末；
- 填空 `fillin` 支持下划线、括号、圆圈、方框、空白，学生版显示 ▲、编号或空白；
- 解答 `solution` 可隐藏、原位显示或集中到文末“参考答案”，`score` 的引导线在行间公式中也能画到页边；
- 密封线、A3 横向双栏拼版、评分框、草稿纸、试卷合集与目录；
- 语文的材料、古诗与注释、选择标记、连线题、作文格；英语的作文框与横线；
- 图文混排、多图并排、计算题网格、教材写法的数学符号；
- **一份源码同时编译学生版与教师版**，不需要 `-shell-escape`。

## 快速开始

```typ
#import "@preview/exam-zh:0.1.0": *

#show: exam.with(title: [2021 年普通高等学校招生全国统一考试], subject: [数学])

#secret()
#make-title()

= 选择题：本题共 8 小题，每小题 5 分，共 40 分。

#question[
  设集合 $A = {x | -1 < x < 4}$，$B = {2, 3, 4, 5}$，则 $A inter B = $ #paren[B]
  #choices(answer: "B")[${2}$][${2, 3}$][${3, 4}$][${2, 3, 4}$]
]

= 填空题：本题共 4 小题，每小题 5 分，共 20 分。

#question[
  已知函数 $f(x) = x^3 (a dot 2^x - 2^(-x))$ 是偶函数，则 $a = $ #fillin[$1$]。
]
```

```sh
typst compile exam.typ                                            # 学生版
typst compile --input exam-mode=teacher exam.typ exam-teacher.pdf # 教师版
```

`typst init @preview/exam-zh` 生成一份可直接修改的试卷。

在本仓库中使用时，把 `@preview/exam-zh:0.1.0` 换成 `src/lib.typ` 的路径，或把仓库放到
`~/.local/share/typst/packages/local/exam-zh/0.1.0` 后导入 `@local/exam-zh:0.1.0`。

## 文档与示例

两份文档与 LaTeX 版的两份文档一一对应：

- [入门指南](docs/guide.typ)（对应 `exam-zh-doc-basic.pdf`）：快速开始、基础概念、各种题型、常见场景、完整示例、FAQ，章节与示例和 LaTeX 版入门文档相同；
- [API 对照手册](docs/reference.typ)（对应 `exam-zh-doc.pdf`）：*章节编号与 LaTeX 版完整文档相同*，每个命令、环境和 `\examsetup` 键值都给出 LaTeX 写法、Typst 写法、说明，以及原文档示例的 LaTeX 代码、Typst 代码和效果；最后一章是全部选项与默认值。

示例在 [examples/](examples/) 中，与 LaTeX 版的示例一一对应：

- `example-single.typ`：2021 年全国乙卷数学；
- `example-multiple.typ`：A3 密封线试卷合集，带目录，两份试卷共用 `papers/` 中的同一份题目；
- `basic/00-minimal.typ` 到 `basic/04-english-basic.typ`：入门示例，包括语文、英语和带密封线与草稿纸的真实考试场景。

在仓库根目录编译：`typst compile --root . examples/example-single.typ`、`typst compile --root . docs/guide.typ`。

## 设置

所有选项按模块分组，三个入口的键名相同：

```typ
#show: exam.with(choices: (max-columns: 2))   // 整份试卷
#exam-setup(fillin: (type: "paren"))          // 从此处往后
#choices(columns: 2)[A][B][C][D]               // 只作用于这一次
```

键名写错时编译报错，例如 ``unknown option `choices.colums` ``。全部选项见
[`src/config.typ`](src/config.typ) 中的 `default-config` 与手册最后一章。

## 字体

`font.preset` 选择一组中文字体：

| preset | 宋体 | 黑体 | 楷体 | 仿宋 |
|---|---|---|---|---|
| `noto`（默认） | Noto Serif CJK SC | Noto Sans CJK SC | （同宋体） | （同宋体） |
| `source-han` | Source Han Serif SC | Source Han Sans SC | （同宋体） | （同宋体） |
| `fandol` | FandolSong | FandolHei | FandolKai | FandolFang |
| `windows` | SimSun | SimHei | KaiTi | FangSong |
| `mac` | Songti SC | Heiti SC | Kaiti SC | STFangsong |
| `founder` | FZShuSong-Z01 | FZHei-B01 | FZKai-Z03 | FZFangSong-Z02 |

Noto 与思源字体没有楷体，可以单独指定，例如 `font: (kai: "LXGW WenKai")`。
西文默认使用 Typst 自带的 New Computer Modern，数学使用 New Computer Modern Math。
Typst 不会伪造粗体，请使用带粗体字重的中文字体。

## 从 exam-zh 迁移

| exam-zh (LaTeX) | exam-zh (Typst) |
|---|---|
| `\documentclass{exam-zh}`、`\examsetup{...}` | `#show: exam.with(...)`、`#exam-setup(...)` |
| `\title`、`\subject`、`\maketitle` | `exam(title:, subject:)`、`make-title()` |
| `\secret`、`\information`、`\warning`、`notice` | `secret()`、`information(..)`、`warning[..]`、`notice[..][..]` |
| `\section{...}` | `= ...` |
| `question`、`problem[points = 12]` | `question[..]`、`problem(points: 12)[..]` |
| `choices` 与 `\item`、`\item*` | `choices[..][..]`，`answer: "B"` 标记正确选项 |
| `\paren[B]`、`\paren*` | `paren[B]`、`paren(wide: true)` |
| `\fillin[答案]`、`\fillin[type = paren][]`、`\fillin*` | `fillin[答案]`、`fillin(type: "paren")`、`fillin(breakable: true)` |
| `solution`、`\score{2}` | `solution[..]`、`score(2)` |
| `step`、`method`、`case` | `step[..][..]`、`method[..][..]`、`case[..][..]` |
| `\draftpaper`、`\examsquare{9}`、`\scoringbox`、`\scoringbox*` | `draftpaper()`、`examsquare(9)`、`scoringbox()`、`scoringbox(simple: true)` |
| `\chapter`、`\tableofcontents` | `chapter[..]`、`exam-outline()` |
| `select` 与 `\sitem*` | `select(answer: 2)[..][..]` |
| `lineto`、`\linelistset`、`\lineconnect` | `lineto((..), (..), connect: ((1, 3), ..))` |
| `material`、`poem`、`\zhu` | `material(..)[..]`、`poem(..)[..]`、`zhu[..]` |
| `\compositiongrid{1000}` | `composition-grid(1000)` |
| `writingbox`、`\writinglines{8}`、`\writingline` | `writingbox[..]`、`writinglines(8)`、`writingline()` |
| `multifigures` 与 `\item[标签]` | `multifigures(([标签], image(..)), ..)` |
| `\textfigure{文字}{图片}` | `textfigure[文字][图片]` |
| `calculations` | `calculations[..][..]` |
| `\eu`、`\iu`、`\uppi`、`\vec` | `eu`、`iu`、`uppi`、`vect` |
| 重定义的 `\parallel`、`\cong`、`\sim` 等 | `#import symbols: *` |
| `\circlednumber*`、`\tikzcirclednumber`、`\AddQuestionCounter` 等 | 编号格式 `"①"`（超过 50 自动绘制）、`circled-number(n)`，或 `label: n => ..` |
| `symbols/change-frac-style`、`frac-add` | `symbols: (frac-add: 5em / 18)` |
| `style/footnote-style` | `style: (footnote-numbering: "①")` |
| `\ExamPrintAnswerSet` 与 `-shell-escape` | `--input exam-mode=teacher` 与 `exam(teacher: ..)` |
| `\everymath{\displaystyle}` | `style: (display-math: true)` |
| `style/fullwidth-stop = catcode` | `style: (fullwidth-stop: true)` |

### 有意的改动

- **题号 `index`** 与 exam-zh 相同，表示下一题的题号；`exam-setup(question: (index: 1))` 让题号从 1 重新开始。
- **连线与选择标记**属于答案：学生版默认不画连线、不显示标记，教师版自动显示。exam-zh 中 `\lineconnect` 总是画线。
- **楷体**：Noto 与思源预设没有楷体时，材料与古诗退回宋体，而不是报找不到字体的警告。
- **密封线开关**是 `sealline: (enable: true)`，因为 `show` 是 Typst 的关键字。

### 留给独立包的功能

以下两项属于独立的排版能力，适合各自做成单独的 Typst 包，再由本模板选用：

- **文字绕排**（exam-zh 的 `wrapstuff` 与 `textfigure` 的 `top`）：Typst 尚不支持文字绕排浮动内容。
  现有的 [meander](https://typst.app/universe/package/meander) 已能让文字绕排任意形状，
  [wrap-it](https://typst.app/universe/package/wrap-it) 支持矩形绕排，目前可以直接使用它们。
- **汉字格**（exam-zh 通过 `hanzibox` 提供的更多格子类型与拼音格）：`composition-grid` 已绘制口、田、米三种格子；
  四线三格、拼音格等更多类型适合作为独立的汉字格包。

### 不需要移植的选项

- `style/student-version-suffix`、`student-version-cleanaux`：Typst 在命令行中指定输出文件，没有辅助文件需要清理。
- `composition-grid/hanzibox-options` 与 `cell-format`、`multifigures` 的第二个（tabularray）参数：
  这些是传给 LaTeX 宏包的原始参数；对应的设置分别是 `cell-size`、`frame-type` 等选项与 `multifigures(column-widths: ..)`。
- `symbols/change-dfrac-style`、`dfrac-add`：Typst 不区分 `\frac` 与 `\dfrac`，`symbols.frac-add` 作用于所有分式。

## 开发

```sh
scripts/check.sh [--font-path DIR]
```

编译全部示例（学生版与教师版）、测试与两份文档，出现错误或警告即失败。文档中密封线、A3 拼版等整页效果的图片由
`scripts/doc-images.sh` 从示例生成，修改示例后重新运行它。

## 致谢

设计、选项与示例来自 exam-zh（作者 Zeping Lee，维护者 Kangwei Xia、Lijun Guo，LPPL 1.3c）。
本仓库的 Typst 代码为独立实现。
