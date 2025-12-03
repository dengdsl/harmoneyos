import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { JSON } from '@kit.ArkTS'

@Entry
@Component
struct Index {
  @State btnMessage: string = '冷启动C页面'
  build() {
    Column() {
      Text("在应用内拉起其他UIAbility")
        .fontSize(30)
        .fontColor("#01ba89")
        .margin({
          top: 30,
        })
        .padding(10)
        .textAlign(TextAlign.Center)
        .width("100%")

      Row() {
        Button("跳转A页面").type(ButtonType.Normal).borderRadius(6).margin({
          right: 10
        })
          .onClick(() => {
            const context = this.getUIContext().getHostContext() as common.UIAbilityContext

            const wantInfo: Want = {
              deviceId: "",
              bundleName: "com.example.myapplication",
              moduleName: "entry",
              abilityName: "FuncAAbility",
              parameters: {
                nameStr: 'index',
                pageStr: 'pages/index',
                desc: '这是从index页面传递过来的自定义参数'
              }
            }
            // 调用startAbility拉起其他UIAbility
            context.startAbility(wantInfo).then(() => {
              console.log("成功跳转到A页面")
            }).catch((err: BusinessError) => {
              console.error('调用 startAbility 异常:', JSON.stringify(err))
            })
          })
        Button("跳转B页面").type(ButtonType.Normal).borderRadius(6).onClick(() => {
          console.log("跳转到B页面")
          const context = this.getUIContext().getHostContext() as common.UIAbilityContext
          const want: Want = {
            deviceId: '',
            bundleName: "com.example.myapplication",
            moduleName: "entry",
            abilityName: "FuncBAbility",
            parameters: {
              req: '这是我的请求信息，返回的信息请用rsp字段进行返回'
            }
          }
          let RESULT_CODE = 1001
          // 跳转到B页面并监听B页面返回的数据信息
          context.startAbilityForResult(want).then((data) => {
            if (data?.resultCode === RESULT_CODE) {
              // 获取B页面返回的数据信息
              const rsp = data.want?.parameters?.rsp
              console.info("从B页面返回的数据 ==>", JSON.stringify(rsp) )
            }
            console.error("resultCode ==>", JSON.stringify(data.resultCode))
          }).catch((err: BusinessError) => {
            console.error("跳转到B页面失败 ==>", err.message)
          })
        })
      }.margin({
        top: 50
      })

    }.backgroundColor("#f5f5f5")
    .height("100%")
    .width("100%")
  }
}