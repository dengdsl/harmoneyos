/**
 * http数据请求
 * 请求方法： GET、POST、OPTIONS、HEAD、PUT、DELETE、TRACE、CONNECT
 * 请求方式
 *  1、数据量小，可使用HttpRequest.request
 *  2、大文件上传或下载，且还珠数据发送和接收进度，可使用HTTP请求流失传输,HttpRequest.requestInStream
 *
 * 发起Http请求步骤如下
 *  1、导入HTTP一般数据请求所需模块
 *  2、调用createHttp方法，创建HttpRequest请求对象
 *  3、使用请求对象的on方法，订阅HTTP响应头事件，此接口会比request请求先返回，可以根据业务需要订阅此消息
 *  4、调用请求对象的request方法，传入Http请求的url地址和可选参数，发起网络请求，按照实际业务需要，解析返回结果
 *  5、调用请求对象的off方法，取消订阅HTTP响应头事件
 *  6、当请求使用完毕时，调用destroy方法销毁
 * */
import {http} from "@kit.NetworkKit"
import { JSON } from "@kit.ArkTS"

function sendHttpRequest(){
  // 2、创建请求对象
  const httpRequest = http.createHttp()

  // 3、订阅HTTP响应事件
  httpRequest.on("headersReceive", (header) => {
    console.info("header ==>", JSON.stringify(header))
  })

  // 4、发起请求
  httpRequest.request("具体的请求地址", {
    method: http.RequestMethod.POST, // 请求方法，可选参数，默认为http.RequestMethod.GET
    header: {
      "Content-Type": 'application/json' // 请求体参数类型
    },
    extraData: '', // 当使用POST请求时此字段用于传递请求体内容，具体格式与服务端协商确定
    expectDataType: http.HttpDataType.STRING, // 指定返回数据的类型
    usingCache: true, // 指定是否使用缓存，默认为true
    connectTimeout: 60000, // 连接超时时间
    readTimeout: 6000, // 从连接到读取响应的时间，默认为6000毫秒
    usingProxy: false, // 是否使用网络代理
    caPath: '证书路径', // 使用系统预制证书
    clientCert: { // 可选
      certPath: '', // 证书路径
      keyPath: '', // 若证书包含key信息，传入空字符串
      certType: http.CertType.PEM, // 证书类型
    },
    multiFormDataList: [
      {
        name: '数据名称',
        contentType: 'text/plain', // 数据类型
        filePath: '文件路径',
        remoteFileName: '文件名称'
      }
    ]
  }, (err: BusinessError, data: http.HttpResponse) => {
    if (!err) {
      console.info("请求响应的数据 ==>", JSON.stringify(data.result))
      console.info("请求响状态码 ==>", JSON.stringify(data.responseCode))
      console.info("请求响应头部信息 ==>", JSON.stringify(data.header))
      console.info("请求响应的cookie信息 ==>", JSON.stringify(data.cookies))
      // 当该请求使用完毕时，调用destroy方法销毁请求对象
      httpRequest.destroy()
    }else {
      console.info("请求失败")
      // 5、取消订阅
      httpRequest.off("headersReceive")
      // 6、销毁请求对象
      httpRequest.destroy()
    }
  })
}



/**
 * 发起Http流式传输请求：该方式是指在处理HTTP响应时，可以一次只处理响应内容的一小部分，而不是一次性将整个响应加载到内存，这对于处理大文件，实施数据流邓场景非常有用
 * 使用步骤如下
 * 1、导入http模块
 * 2、创建请求对象，调用createHttp方法
 * 3、当月http流响应事件，服务器响应的数据在dataReceive回调中返回，可通过订阅该信息获取服务器响应的数据，其他流式响应事件可按需进行订阅
 * 4、发起流式请求，调用requestInStream方法
 * 5、取消步骤三中订阅的http流响应事件，并调用destroy销毁流式HTTP请求，调用off方法取消订阅，
 * */
function sendHttpStreamRequest(){
  let res:ArrayBuffer = new ArrayBuffer(0)
  // 2、创建请求对象
  const httpRequest = http.createHttp()
  // 3、按需订阅流响应事件
  httpRequest.on("dataReceive", (data: ArrayBuffer) => {
    const newRes = new ArrayBuffer(res.byteLength + data.byteLength)
    const resView = new Uint8Array(newRes)
    resView.set(new Uint8Array(res))
    resView.set(new Uint8Array(data), res.byteLength)
    res = newRes
    console.info("当前读取到的数据 ==>", res.byteLength)
  })
  // 订阅数据接受完成事件
  httpRequest.on("dataEnd", () => {
    console.info("数据传输完成")
    // 在这个事件中取消订阅和销毁请求对象
    closeHttpStreamRequest(httpRequest)
  })
  // 订阅数据进度事件
  httpRequest.on("dataReceiveProgress", (data: http.DataReceiveProgressInfo) => {
    console.info("当前传输长度 ==>", data.receiveSize, "数据总长度 ==>", data.totalSize)
  })
  // 订阅发送进度事件
  httpRequest.on("dataSendProgress", (data: http.DataSendProgressInfo) => {
    console.info("当前数据发送长度 ==>", data.sendSize, "数据总长度 ==>", data.totalSize)
  })
}

function closeHttpStreamRequest(httpRequest: http.HttpRequest) {
  httpRequest.off("dataEnd")
  httpRequest.off("dataReceiveProgress")
  httpRequest.off("dataSendProgress")
  httpRequest.off("dataReceive")
  // 5、销毁
}