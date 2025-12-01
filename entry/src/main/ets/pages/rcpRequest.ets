import { rcp } from '@kit.RemoteCommunicationKit'
import { JSON } from '@kit.ArkTS'


/**
 * 实现基础的网络请求，实现思路如下
 * 在创建session会话后，通过创建请求对象并传入第二个参数且指定为PATCH，燃弧用过session.fetch发起请求即可
 * 1、导入RCP模块
 * 2、创建headers，设置可接受的数据内容的类型为json字符串，创建modifiedContent，传入想要修改的内容
 * 3、调用rcp。createSession()创建通信会话对象session
 * 4、使用new rcp.Request方法创建请求对象req
 * 5、调用session.fetch方法发起请求
 * 6、获取响应结果
 *
 * 设置会话中的基础地址，通过sessionConfig对象中的baseAddress进行设置
 *
 * */
interface UserInfo {
  userName: string;
}

function sendRcpRequest(){
  // 1、定义headers对象
  const headers: rcp.RequestHeaders = {
    "accept": 'application/json',
  }
  // 2、定义想要修改的内容
  const modifiedContent: UserInfo = {
    userName: 'xxxxx'
  }
  // 创建session对象
  const securityConfig: rcp.SecurityConfiguration = {
    tlsOptions: {
      tlsVersion: "TlsV1.3"
    }
  }
  const session = rcp.createSession({
    baseAddress: '这是服务器的基础地址',
    requestConfiguration: {
      security: securityConfig
    }
  })

  // 3、创建请求对象req
  const req = new rcp.Request("url", 'PATCH', headers, modifiedContent)

  // 4、发起请求
  session.fetch(req).then((response: rcp.Response) => {
    console.info("请求响应结果 ==>", JSON.stringify(response))

  }).catch((err: BusinessError) => {
    console.info("请求失败 ==>", err.code, err.message)
  })
}

/**
 * 多表单提交：同页面下tab栏可切换多个Form表单组件，但是只有一个提交按钮，各组件下的表单数据需要被一起提交，此时可以使用RCP模块中的MultipartGForm来实现多表单提交的场景
 * 实现思路如下
 * 1、导入RCP模块
 * 2、设置请求头类型、配置HTTP请求的超时值、HTTP请求中包含的cookie和设置传输数据范围
 * 3、调用rcp.createSession()创建通信会话对象
 * 4、通过new rcp.Request创建请求对象，调用session.fetch方法发起请求
 * 6、处理响应结果
 *
 * */
function sendRcpMultipartRequest(){
  // 1、定义headers对象
  const headers: rcp.RequestHeaders = {
    "accept": 'application/json',
  }
  // 配置http请求的超时值
  const configuration: rcp.Configuration = {
    transfer: {
      timeout: {
        connectMs: 6000,
        transferMs: 6000
      }
    }
  }
  // http请求中的cookie
  const cookie: rcp.RequestCookies = {
    'name1': 'value1',
    'name2': 'value2'
  }
  // 设置数据传输范围
  const transferRange: rcp.TransferRange = {
    from: 100,
    to: 200
  }
  // 设置多表单数据
  const multiForm = new rcp.MultipartForm({
    'form1': '这是第一个表单数据',
    'form2': '这是第二个表单数据',
    'forms': {
      contentType: "text/plain",
      remoteFileName: 'RemoteFileName',
      contentOrPath: '/file/to/path'
    }
  })
  const securityConfig: rcp.SecurityConfiguration = {
    tlsOptions: {
      tlsVersion: "TlsV1.3"
    }
  }
  // 创建session对象
  const session = rcp.createSession({
    requestConfiguration: {
      security: securityConfig
    }
  })
  // 创建请求对象req
  const req = new rcp.Request('url', "POST", headers, multiForm, cookie, transferRange, configuration)
  // 发起请求
  session.fetch(req).then(res => {
    console.info("多表单请求成功 ==>", JSON.stringify(res))
  }).catch((err: BusinessError) => {
    console.info("多表单请求失败 ==>", err.code, err.message)
  })
}

/**
 * 实现请求与响应拦截：RCP模块提供了拦截器的能力，在SessionConfiguration中添加Interceptors参数，传入自定义的拦截器，即可在Http请求和响应过程中添加拦截器功能
 * 工作原理：客户端发起HTTP请求，到达目标服务器之前，可以使用拦截器对HTTP的请求进行修改，定义了ResponseCachingInterceptor拦截器和ResponseHeaderRemoveInterceptor
 * 请求先被ResponseCachingInterceptor拦截，该拦截器中可以对请求的响应结果惊醒缓存，然后经过ResponseHeaderRemoveInterceptor，最后请求到达Internet，
 * 当请求到达目标服务器，服务器返回请求响应结果给客户端之前，可以使用拦截器对响应结果进行修改，响应先辈ResponseHeaderRemoveInterceptor拦截，在响应返回给应用之前检查和修改服务器的请求头，然后经过ResponseCachingInterceptor，最后客户端接受响应结果
 *
 * 说明：这两个拦截器都是自定义拦截器，需要开发者通过代码区实现内部内逻辑
 *
 * 拦截器的定义和使用：定义ResponseCachingInterceptor拦截器和ResponseHeaderRemoveInterceptor拦截器实现rcp.Interceptor，可在interceptor方法中根据业务需求自定义处理逻辑，实现对请求/响应的修改
 * 实现步骤如下
 * 1、导入rcp模块
 * 2、定义ResponseCachingInterceptor拦截器和ResponseHeaderRemoveInterceptor拦截器
 * 3、在Interceptor方法中实现对请求/响应的修改逻辑
 * */
export class  ResponseCache {
  public readonly cache: Record<string, rcp.Response> = {}

  // 从缓存中获取数据
  getResponse(url: string): rcp.Response {
    return this.cache[url]
  }
  // 将数据设置到缓存中
  setResponse(url: string, response: rcp.Response ) {
    this.cache[url] = response
  }
}

export class  ResponseCachingInterceptor implements rcp.Interceptor {
  public readonly cache: ResponseCache;

  constructor(cache: ResponseCache) {
    this.cache = cache
  }

  // 实现拦截器代码逻辑
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // 从缓存中获取数据
    const url = context.request.url.href
    const responseFromCache = this.cache.getResponse(url)
    if (responseFromCache) {
      return Promise.resolve(responseFromCache)
    }

    //
    AppStorage.SetOrCreate("ReplacedInfo", `[ResponseCachingInterceptor]: Request URL is ${url}`)
    const promise = next.handle(context)
    promise.then((rsp) => {
      console.info("响应状态码 ==>", rsp.statusCode)
      // 将数据进行缓存
      this.cache.setResponse(url, rsp)
    })

    return promise
  }
}
export class ResponseHeaderRemoveInterceptor implements rcp.Interceptor {

  // 实现拦截器功能
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // 获取服务器响应
    const response = await next.handle(context)
    // 修改服务器响应头部信息
    const toReturn: rcp.Response = {
      request: response.request,
      statusCode: response.statusCode,
      httpVersion: response.httpVersion,
      headers: {
        "accept-ranges": response.headers['accept-ranges']
      },
      effectiveUrl: response.effectiveUrl,
      timeInfo: response.timeInfo,
      toJSON: () => null
    }
    console.info("修改之后的响应头 ==>", JSON.stringify(toReturn))
    return toReturn
  }
}

// 拦截器的使用
function useInterceptorInRequest(){
  // 创建缓存对象，在ResponseCachingInterceptor拦截器中需要传递
  const cache = new ResponseCache()
  const sessionConfig: rcp.SessionConfiguration = {
    interceptors: [new ResponseCachingInterceptor(cache), new ResponseHeaderRemoveInterceptor()],
    requestConfiguration: {
      security: {
        tlsOptions: {
          tlsVersion: "TlsV1.3"
        }
      }
    }
  }
  // 创建session对象
  const session = rcp.createSession(sessionConfig)
  // 创建request对象
  const request = new rcp.Request("url", "POST")
  // 发起请求
  session.fetch(request).then(rsp => {
    console.info("这是经过拦截器处理过的响应结果 ==>", JSON.stringify(rsp))
  }).catch((err: BusinessError) => {
    console.info("使用拦截器发送请求失败 ==>", err.code, err.message)
  })
}