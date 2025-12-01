
import {connection, socket} from "@kit.NetworkKit"
import {BusinessError} from "@kit.BasicServicesKit"

let netSpecifier: connection.NetSpecifier = {
  netCapabilities: {
    bearerTypes: [connection.NetBearType.BEARER_CELLULAR],
    networkCap: [connection.NetCap.NET_CAPABILITY_INTERNET]
  }
}
const timeout = 10 * 1000
// 调用createNetConnection方法，指定网络能力、网络类型和网络时间
let conn = connection.createNetConnection(netSpecifier, timeout)

// 监听网络，如果当前网络可用，通知用户
conn.on("netAvailable", (data: connection.NetHandle) => {
  console.log("data ==>", data)
})

// 监听网络
conn.on("netUnavailable", (data: void) => {
  console.info("当前网络不可用，data is ==>", JSON.stringify(data))
})

// 调用conn对象的register方法，订阅网络状态变化的通知，此接口要在调用on后调用，当网络可用时，会用到netAvailable事件的回调，当网络不可用时，会收到netUnavailable事件的回调
conn.register((err: BusinessError, data: void) => {
  console.info("err is ==>", JSON.stringify(err) , 'data is ==>', JSON.stringify(data))
})

// 当不使用该网络时，可以调用该对象的unregister方法取消订阅
conn.unregister((err: BusinessError, data: void) => {
  console.info("err is ==>", JSON.stringify(err) , 'data is ==>', JSON.stringify(data))
})

// 默认网络变化后重新建立网络连接，原网络使用Socket模块建立连接
let sock: socket.TCPSocket = socket.constructTCPSocketInstance()
function useSocket() {
  let socketAddress: socket.NetAddress = {
    address: '192.168.xxx.xxx', // 服务器IP
    port: 80 // 端口号
  }
  const tcpOptions: socket.TCPConnectOptions = {
    address: socketAddress,
    timeout: 60000 // 连接超时时间
  }
  // 建立socket连接
  sock.connect(tcpOptions, (err: BusinessError) => {
    if (err) {
      console.error('socket connect error:', err)
      return
    }
    console.log('socket connect success')
    let tcpSendOptions: socket.TCPSendOptions = {
      data: 'Hello, world!',
    }
    socketSend(tcpSendOptions)
  })
}

// 通过socket发送数据
function socketSend(tcpSendOptions: socket.TCPSendOptions) {
  sock.send(tcpSendOptions).then((data: void) => {
    console.info('socket send success:', data)
  }).catch((err: BusinessError) => {
    console.error('socket send error:', err)
  })
}

function socketTest(){
  const netConnection = connection.createNetConnection()
  // 网络切换会导致网络发生中断，原socket失效，故需要重新建立socket连接
  netConnection.on('netAvailable', (netHandle: connection.NetHandle) => {
    console.info("default network changed", JSON.stringify(netHandle))
    sock.close()
    sock = socket.constructTCPSocketInstance()
    useSocket()
  })
  // 订阅网络状态变化的通知
  netConnection.register((err: BusinessError, data: void) => {
    if (err) {
      console.error('netConnection register error:', err)
    }else {
      console.log('netConnection register success:', data)
    }
  })
}

// socketTest()

@Entry
@Component
struct networkInfo{

  build() {
    Column(){
      Text("这个页面描述了怎么链接一个网络，并使用socket发送和接收数据等等")
    }
  }
}