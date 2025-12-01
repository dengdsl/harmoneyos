import { connection } from "@kit.NetworkKit"
import { JSON } from "@kit.ArkTS"

// 源网络使用Socket  Library建立网络连接， 获取所有注册的网络
connection.getAllNets().then((data: connection.NetHandle[]) => {
  console.info("成功获取到所有注册的网络 ==>", JSON.stringify(data))
  if (data) {
    // GlobalContext.getContext().netList = data
  }
})

/**
 * 查看默认网络或者指定网络连接信息，
 * 调用getDefaultNET方法，获取默认的数据网络（NetHandle），
 * 调用getNetCapabilities方法，获取该NetHandle对应网络的能力信息，
 * 也可以调用getConnectionProperties方法获取该NetHandle对应网络的连接信息
 * */
function getDefaultNetsInfo() {
  let netHandleInfo: connection.NetHandle | null = null
  connection.getDefaultNet().then((data: connection.NetHandle) => {
    if (data.netId == 0) {
      console.info("当前无默认网络，获取的netHandler的netId为0，属于异常情况，需要额外处理")
      return
    }
    if (data) {
      // 获取netHandler对应网络的能力信息，能力包含了网络类型，网络几天能力等网络信息
      netHandleInfo = data
      connection.getNetCapabilities(netHandleInfo).then((data: connection.NetCapabilities) => {
        console.info("获取到的网络能力信息 ==>", JSON.stringify(data))
        // 获取网络类型
        let bearerTypes: Set<number> = new Set(data.bearerTypes)
        let bearerTypesNum = Array.from(bearerTypes.values())
        for (let item of bearerTypesNum) {
          if (item == 0) {
            console.info("蜂窝网络")
          } else if (item == 1) {
            console.info("WiFi网络")
          } else if (item == 3) {
            console.info("以太网网络")
          }
        }
        // 获取具体网络对应的能力
        let itemNumber: Set<number> = new Set(data.networkCap)
        let dataNumber = Array.from(itemNumber.values())
        for (let item of dataNumber) {
          if (item == 0) {
            console.info("表示网络可以王文运营商的MMSC（Multimedia Service，多媒体短信服务）发送和接收短信")
          } else if (item == 11) {
            console.info("表示网络流量未计费")
          } else if (item == 12) {
            console.info("表示该网络应具有访问Internet的能力，该能力由网络提供者设置")
          }else if (item == 15) {
            console.info("表示该网络不使用VPN（virtual private network虚拟专用网络）")
          }else if (item == 16) {
            console.info("表示该网络访问internet的能力被网络管理成功验证，该能力由网络管理模块设置")
          }
        }
      })
    }
  })
  // 获取netHandle对应的网络的连接信息
  connection.getConnectionProperties(netHandleInfo).then((data: connection.ConnectionProperties) => {
    console.info("当前网络对应的能力信息 ==>", JSON.stringify(data))
  })
}

/**
 * 获取所有网络连接信息代码示例
 * 通过调用getAllNets方法，获取所有处于连接状态的网络列表，然后遍历网络列表，分别调用geyNetCapabilities方法，
 * 获取该NetHandle对应网络的能力信息，能力信息包含了网络类型（蜂窝网络、WIFI、以太网）
 * 也可以调用getConnectionProperties方法，获取该NetHandle对应网络的连接信息
 * */
function getAllNetsInfo(){
  connection.getAllNets().then((data: connection.NetHandle[]) => {
    console.info("所有网络信息获取成功 ==>", JSON.stringify(data))
    if (data) {
      let handleSet: Set<connection.NetHandle> = new Set(data)
      let handleList = Array.from(handleSet)
      for (let item of handleList) {
        // 循环遍历网络列表每个netHandle对应网络的能力信息
        connection.getNetCapabilities(item).then((data: connection.NetCapabilities) => {
          console.info("当前网络的能力信息 ==>", JSON.stringify(data))
        })
        connection.getConnectionProperties(item).then((data: connection.ConnectionProperties) => {
          console.info("当前网络对应的连接信息 ==>", JSON.stringify(data))
        })
      }

    }
  })
}

/**
 * 判断默认网络是否可以访问互联网
 * 调用getDefaultNetSync方法，获取当前默认网络的netHandle，netHandle有效的情况下，调用getNetCapabilitySync方法，获取对应网络能力信息
 * 判断networkCap数组中的值是否可用，NET_CAPABILITY_CHECKING_CONNECTIVITY表示在进行连通性判断的过程中，
 * 当不处于连通性判断过程中，且networkCap数组中包含NET_CAPABILITY_VALISATE表示网络连通性校验通过，可以访问互联网
 * */
function checkNetworkIsValidate(){
  const netHandle: connection.NetHandle = connection.getDefaultNetSync()
  if (!netHandle || netHandle.netId == 0) {
    console.info("不存在默认网络")
  }else {
    // 获取对应的网络能力信息
    const nerCapAbilitys = connection.getNetCapabilitiesSync(netHandle)
    const cap = nerCapAbilitys.networkCap
    // 判断是否可以访问互联网
    if (cap?.includes(connection.NetCap.NET_CAPABILITY_CHECKING_CONNECTIVITY)) {
      console.info("正在验证网络连通性，请稍后重试！")
    }else {
      if (cap?.includes(connection.NetCap.NET_CAPABILITY_VALIDATED)) {
        console.info("网络连通性验证成功，当前默认网络可以访问互联网")
      }else {
        console.info("网络连通性验证失败")
      }
    }
  }
}

/**
 * 使用默认网络解析域名，获取所有IP
 * 调用getAddressByName方法，使用默认网络解析主机名以获取所有IP地址
 * */
function getNetworkIpByAddress(){
  connection.getAddressesByName('xxxx').then((data: connection.NetAddress[]) => {
    console.info("网络IP获取成功 ==>", JSON.stringify(data))
  })
}
