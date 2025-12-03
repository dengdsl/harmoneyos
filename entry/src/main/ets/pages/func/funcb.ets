import { common } from '@kit.AbilityKit'


@Entry
@Component
struct FuncB {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext
  build() {
    Column(){
      Text("这个页面用于接收上个页面传递的数据，并且会返回结果给上一个页面").fontSize(20).fontColor("#10b8a9").padding(10)

      Button("点击我携带数据返回").type(ButtonType.Normal).borderRadius(6).margin({
        top: 10
      }).onClick(() => {
        console.log("创建数据返回")
        let data: common.AbilityResult = {
          resultCode: 1001,
          want: {
            deviceId: '',
            bundleName: 'com.example.myapplication',
            moduleName: 'entry',
            abilityName: 'EntryAbility',
            parameters: {
              rsp: '这是我按照要求返回的数据信息'
            }
          }
        }
        this.context.terminateSelfWithResult(data, (err) => {
          if (err?.code) {
            console.error("数据返回失败")
          }else {
            console.log("数据返回成功 ==>", JSON.stringify(err))
          }
        })
      })
    }.backgroundColor("#f5f5f5").width("100%").height("100%")
  }
}