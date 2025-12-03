import { common } from '@kit.AbilityKit'

@Entry
@Component
struct FuncA {
  private  context = this.getUIContext().getHostContext() as common.UIAbilityContext
  build() {
    Column(){
      Text("当页面的业务逻辑处理完成之后，点击下面的按钮可以停止当前Ability").fontSize(20).fontColor("#10b8a9").padding(10)
      Button("停止当前实例").type(ButtonType.Normal).borderRadius(6).margin({
        top: 10
      }).onClick(() => {
        // 停止当前实例通过调用terminateSelf，该方法停止实例后在任务列表可以看到实例快照，如果不需要保留快照，需要在module.json5配置文件中，将abilities标签的removeMissionAfterTerminate字段配置为true
        this.context.terminateSelf((err) => {
          if (err.code) {
            console.error("停止当前实例失败", err.message)
          }else {
            console.info("停止当前实例成功")
          }
        })
      })

      Text("如果想要完全杀死该实例，需要调用ApplicationContext的killAllProcesses方法关闭所有的应用进程").fontSize(20).fontColor("#10b8a9").padding(10).margin({
        top: 100
      })
    }.backgroundColor("#f5f5f5").width("100%").height("100%")
  }
}