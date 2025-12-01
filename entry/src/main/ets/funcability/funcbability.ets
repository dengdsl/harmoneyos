import { AbilityConstant, UIAbility, Want } from "@kit.AbilityKit";

export class FuncBAbility extends UIAbility{

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log("在OnCreate收到的自定义参数 ==>", JSON.stringify(want.parameters))
  }
  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    console.log("在onNewWant中收到的自定义参数 ==>", JSON.stringify(want.parameters))
  }
}