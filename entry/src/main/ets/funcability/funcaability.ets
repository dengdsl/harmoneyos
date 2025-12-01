import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { JSON } from '@kit.ArkTS';
import window from '@ohos.window';

export default class FuncAAbility extends UIAbility {

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log("在OnCreate收到的自定义参数 ==>", JSON.stringify(want.parameters))
  }
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log("在onNewWant中收到的自定义参数 ==>", JSON.stringify(want.parameters))
  }
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent("pages/func/funca", (err) => {
      if (err.code) {
        console.error("页面加载失败 ==>", err.message)
      }else {
        console.log("页面加载成功")
      }

    })
  }
}