import { AbilityConstant, UIAbility, Want } from "@kit.AbilityKit";
import { window } from "@kit.ArkUI";

export class FuncBAbility extends UIAbility{

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log("在OnCreate收到的自定义参数 ==>", JSON.stringify(want.parameters))
  }
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log("在onNewWant中收到的自定义参数 ==>", JSON.stringify(want.parameters))
  }

  // 窗口创建生命周期，需要在该生命周期中指定加载的UI信息
  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent("pages/func/funcb")
  }
}
