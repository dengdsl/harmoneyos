import { common, Want } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { JSON } from '@kit.ArkTS'

@Entry
@Component
struct Index {
  // 声明 context 变量
  private context: common.UIAbilityContext | null = null
  
  aboutToAppear(): void {
    // 从 AppStorage 获取 context
    this.context = AppStorage.get<common.UIAbilityContext>('context') || null
    
    // 如果 AppStorage 中没有，使用 getContext 作为后备方案
    if (!this.context) {
      this.context = getContext(this) as common.UIAbilityContext
    }
    
    // 调试信息
    console.log('===== Context 调试信息 =====')
    console.log('context是否存在:', this.context !== null)
    console.log('startAbility方法类型:', typeof this.context?.startAbility)
    console.log('bundleName:', this.context?.abilityInfo?.bundleName)
    console.log('========================')
  }

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
            // 确保 context 存在
            if (!this.context) {
              console.error("Context未初始化")
              return
            }
            
            // 检查 startAbility 方法是否存在
            console.log('startAbility方法:', typeof this.context.startAbility)

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

            console.log('准备跳转，Want信息:', JSON.stringify(wantInfo))
            
            // 安全调用 startAbility
            try {
              const promise = this.context.startAbility(wantInfo)
              if (promise && promise.then) {
                promise.then(() => {
                  console.log("成功跳转到A页面")
                }).catch((err: BusinessError) => {
                  console.error(`跳转失败 code: ${err.code}, message: ${err.message}`)
                })
              } else {
                console.error('startAbility 返回值异常，可能在模拟器环境下不支持')
              }
            } catch (err) {
              console.error('调用 startAbility 异常:', JSON.stringify(err))
            }
          })
        Button("跳转B页面").type(ButtonType.Normal).borderRadius(6).onClick(() => {
          console.log("跳转到B页面")
        })
      }.margin({
        top: 50
      })
    }.backgroundColor("#f5f5f5")
    .height("100%")
    .width("100%")
  }
}