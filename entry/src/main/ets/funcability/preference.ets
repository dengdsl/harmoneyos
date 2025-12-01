/**
 * 用户首选项：Preferences。为用户提供Key-Value键值对类型的数据处理能力，支持持久化轻量级数据存储、修改、查询
 *
 * 存储模式说明
 * 1、XML存储：该模式的优点是通用性强，支持跨平台，当选择该模式时，首选项对数据的操作主要发生在内存中，开发者可以在需要的时候在调用flush接口进行数据持久化，针对单进程、小数据场景，推荐使用该方式
 * 2、GSKV存储：数据已二进制存储在文件中，该模式的优点是支持多进程并发读写，当选择该模式时，首先想对数据的操作会实时落盘，针对多进程并发场景，推荐使用该模式
 *
 * 约束限制
 * 1、key为string类型，最大长度1024字节
 * 2、如果value为string类型，请使用UTF-8编码格式，可以为空，长度不超过16MB
 * 3、当调用removePreferencesFromCache或者deletePreference后，订阅的数据变更会主动取消订阅，重新getPreferences后需要宠幸订阅数据变更
 * 4、不允许deletePreferences与其他接口多线程、多进程并发调用
 * 5、不支持数据加密存储，如果要加密，应先进行加密，在通过Uint8Array类型存储到Preference中
 *
 * XML模式约束限制
 * 1、无法保证进程并发安全，会有文件损坏和数据丢失的风险，不支持多进程场景下使用
 * 2、当存储的数据中含有非UTF-8格式的字符串时，请使用Uit8array进行存储，否则会造成文件格式错误造成文件损坏
 * 3、内存会随着数据的存储越来越大，建议不超过50MB
 *
 * GSKV模式约束限制
 * 1、不支持跨平台，使用该模式之前需要调用isStorageTypeSupported接口判断当前平台是否支持该模式
 *
 * 接口说明
 * 1、getPreferencesSync(context: Context, options: Options): Preferences    获取Preferences梳理，该接口存在异步接口
 * 2、putSync(key: string, value: ValueType)  将数据写入Preferences实例，可通过flush将Preferences实例持久化，该接口存在异步接口
 * 3、hasSync(key: string): boolean    检查Preferences实例中是否包含给定key的存储键值对，true表示包含，false表示不包含，给定的key不能为空，该接口存在异步接口
 * 4、getSync(key: string, defaultValue: ValueType):ValueType  获取减对应的值，如果值为null或非默认值的类型，将返回默认值，该接口存在异步接口
 * 5、deleteSync(key: string):void  从Preferences实例中删除名为给定的存储键值对，该接口存在异步接口
 * 6、flush(callback: AsyncCallback<void>): void   将当前Preferences实例的数据异步存储到用户首选项持久化未见中
 * 7、on(type: 'change', callback: Callback<string>): void    订阅数据变更，订阅的数据发生变更后，在执行flush方法后，触发callback回调
 * 8、off(type: 'change', callback: Callback<string>): void   取消订阅数据变更
 * 9、deletePreferences(context: Context, options: Options, callback: AsyncCallback<void>): void  从内存中移除指定的Preferences实例，若Preferences实例有对应的持久化文件，则同时删除其持久化文件
 * 10、isStorageTypeSupported(type: StorageType): boolean  判断当前平台是否支持希望使用的存储模式，true表示支持，false表示支持
 *
 * 开发步骤
 * 1、导入@Kit.ArkData模块
 * 2、选择存储模式，默认使用XML模式，通过在options中的storageType参数进行选择
 * 3、获取Preferences实例，使用getPreferencesSync方法获取
 * 4、写入数据，使用putSync方法
 * 5、读取数据，使用getSync方法
 * 6、删除数据，使用deleteSync方法
 * 7、数据持久化，使用flush方法
 * 8、订阅数据变更，通过on方法订阅，
 * 9、删除指定文件，使用deletePreferences方法
 * */

import { preferences } from "@kit.ArkData"
import { UIAbility } from "@kit.AbilityKit";
import window from "@ohos.window";

let dataPreference: preferences.Preferences | null = null
class PreferencesAbility extends UIAbility {

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 获取首选项实例
    const option: preferences.Options = {
      name: 'preference',
      storageType: preferences.StorageType.XML, // 可选。默认为XML，模式一旦指定不能修改
    }
    // 如果想要使用GSKV模式，需要调用isStorageTypeSupport方法判断当前设备是否支持
    if (preferences.isStorageTypeSupported(preferences.StorageType.GSKV)) {
      option.storageType = preferences.StorageType.GSKV
    }
    dataPreference = preferences.getPreferencesSync(this.context, option)

    // 写入数据
    dataPreference.putSync("preference", '这是存储到首选项中的数据')

    // 读取数据
    const data = dataPreference.getSync("preference", "如果获取不到对应的值则返回该默认值")
    console.info("从首选项获取到的数据 ==>", data)
    // 删除数据
    const isSuccess = dataPreference.deleteSync("preference")
    console.info("是否删除成功 ==>", isSuccess)
    // 数据持久化(先判断模式)
    if (option.storageType === preferences.StorageType.XML) {
      dataPreference.flush(() => {
        console.info("成功将首选项实例持久化到对应文件中")
      })
    }
    // 删除preferences实例，如果对应的有持久化文件，连持久化文件一起删除
    preferences.deletePreferences(this.context, option.name, (err) => {
      // 删除成功err的值为undefined
      if (!err) {
        console.info("首选项实例删除成功")
      }else {
        console.info("首选项实例删除失败")
      }
    })
  }
}