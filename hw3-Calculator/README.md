# 复刻科学计算器

本周作业要求按照 MVC 结构设计开发 iphone 经典计算器，在本人完成的作业中

* Main.storyboard 即为 View ，利用 Stack View 及 constrains 实现了自动化布局，并在 Button 的 View 中将科学计算部分按键设置为在 height 为 Regular 时 Hidden 实现在 iphone 上横竖屏时布局的差异化（此处一开始时我将这些按钮设置为当 height 为 Compact 时 installed，但在模拟时出现了莫名奇妙的 bug，故未用 installed 实现布局的差异化）。此外，为每个按键设置 tag，该 tag 作为按键识别的身份标识，方便后续处理。
* ViewController 即为 Controller，在该部分接受按键动作，通过按键的 tag 将该按键转换为枚举类型 Operator 并调用 Model 类的 calculate 方法对按键动作进行处理，并将得到的结果回显到 View
* 为实现科学计算器设计的算法封装于 Model 中，分为以下模块：
  * 将按键 tag 作为 rawValue 枚举类型 OperatorEnum
  * 处理 mc、m+、m-、mr 的 Memory 模块
  * 处理数字输入的 Number 模块
  * 处理单目运算符的 Unary 模块
  * 处理双目运算符及括号的 Binary 模块，在该模块中，通过泛型实现了栈，并利用一个栈及栈内、栈外双优先度完成了中序表达式转换为后续表达式，再利用另一个栈实现后续表达式的计算，实现了对包含括号的双目运算的支持
  * 对外提供调用接口，并处理 ac、rad 等功能键的 Model 模块