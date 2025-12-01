/**
 * 关系型数据库：基于SQLite组件提供了一套完整的对本地数据库进行管理的机制，对外提供了一套增删改查的接口
 *
 * 接口说明
 * 1、getRdbStore(context: Context, config: StoreConfig, callback:AsyncCallback<RdbStore>): void  获取一个RdbStore，操作关系型数据库，用户可以根据自己的需求配置RdbStore的参数，然后通过RdbStore调用相关的接口可以执行相关的数据操作
 * 2、createTransaction(options?: TransactionOptions): Promise<Transaction> 创建一事务对象并开始事务
 * 3、execute(sql: string, args<Array<ValueType>>): Promise<ValueType> 执行包含指定参数的SQL语句
 * 4、insert(table: string, values: ValuesBuket, conflict: ConflictResolution): Promise<number>  根据predicates的指定实例对象从数据库中删除数据
 * 5、update(values: ValuesBucket, predicates: RdbPredicates, callback: AsyncCallback<number>): void 根据predicates的指定实例对象从数据库中删除数据
 * 6、query(predicates: RdbPredicates, columns: Array<string>, callback: AsyncCallback<void>): void  根据指定添加查询数据库中的数据
 * 7、deleteRdbStore(context: Context,name: string, callback: AsyncCallback<void>): void     删除数据库
 * 8、isTokenizerSupported(tokenizer): boolean 判断当前平台是否支持传入的分词器（将文本分解为更小单元的工具，这些单元可以室单词、字词、字符或者其他语言片段）
 *
 * 工作流程
 * 1、获取RdbStore实例、完成数据库建表
 * 2、调用insert接口插入数据
 * 3、根据谓词指定的实力对象，对数据进行修改或删除
 * 4、根据谓词指定的查询条件查找数据，用query方法查找数据，返回一个ResultSet结果集
 * 5、使用数据对象执行数据的插入、删除、更新操作，调用createTransaction方法创建事务对象并执行相应的操作
 * 6、在同路径下辈分数据库，关系型数据库支持手动备份和自动备份
 * 7、从备份数据库中恢复数据，关系型数据库支持两种方式，恢复手动备份数据和恢复自动备份数据
 * 8、删除数据库
 *
 * */
import { UIAbility } from '@kit.AbilityKit';
import window from '@ohos.window';
import { relationalStore } from '@kit.ArkData';

class RdbStore extends UIAbility {

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 若希望使用分词器，可以调用isTokenizerSupported检查希望使用的分词器是否支持当前平台
    const tokenType = relationalStore.Tokenizer.ICU_TOKENIZER
    const tokenTypeIsSupported = relationalStore.isTokenizerSupported(tokenType)
    if (!tokenTypeIsSupported) {
      console.error("当前平台不支持分词器 ==> relationalStore.Tokenizer.ICU_TOKENIZER")
    }
    const store_config: relationalStore.StoreConfig = {
      name: 'RdbTest.db', // 数据库文件名称
      securityLevel: relationalStore.SecurityLevel.S3, // 数据库安全级别
      encrypt: false, // 是否进行数据加密，默认不加密
      customDir: '', // 数据库自定义路径，默认在本应用沙箱目录下创建RdbStore实例
      isReadOnly: false, // 指定数据路是否已只读方式打开，默认为false，表示数据库可读可写，为true时，只允许读取数据，不允许写入数据
      tokenizer: tokenType // 指定用户在全文搜索场景（FTS）下使用那种分词器，默认在FTS下仅支持英文分词，不支持其他语言分词
    }
    /**
     * 先判断数据库版本，如果不匹配则需要进行升降级操作
     * 假设当前数据版本为3，表结构EMPLOYEE（NAME, AGE, SALARY, IDENTIFY）
     * */
    // 建表SQL
    const SQL_CREATE_TABLE = `
    CREATE TABLE IF NOT EXISTS EMPLOYEE(ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT NOT NULL, AGE INTEGER, SALARY REAL, CODES BLOB, IDENTITY UNLIMITED INT)`

    // 获取RdbStore对象实例
    relationalStore.getRdbStore(this.context, store_config, async (err, store) => {
      if (err) {
        console.info("关系型数据库实例获取失败")
        return
      }
      let storeVersion = store.version
      // 数据可创建时，数据库默认版本为0
      if (storeVersion === 0) {
        try {
          // 创建数据表一遍后续调用insert接口插入数据
          await store.execute(SQL_CREATE_TABLE)
          // 设置数据库版本，入参我是为大于0的政数局
          storeVersion = 0
          console.info("数据库创建成功")
        }catch (err) {
          const error = err as BusinessError
          console.info("数据库创建失败 ==>", error.code, error.message)
        }
      }

      // 如果数据库版本部位0 且和当前数据库版本不匹配，需要进行升降级操作
      // 当数据库版本存在并且版本为0，需要从1版本升级到2版本去
      if  (storeVersion == 1) {
        try {
          await store.execute("ALTER TABLE EMPLOYEE ADD COLUMN AGE INTEGER")
          console.info("成功将数据库版本升级到2版本")
          storeVersion = 2
        }catch (err) {
          const error = err as BusinessError
          console.info("数据库从版本1升级到版本2 ==>", error.code, error.message)
        }
      }
      // 当数据库存在并且版本为2， 数据库需要从2版本升级到3版本去
      if (storeVersion === 2) {
        try {
          await store.execute("ALTER TABLE EMPLOYEE DROP COLUMN ADDRESS")
          storeVersion = 3
          console.info("数据库版本成功从2版本升级到3版本")
        }catch (err) {
          const error = err as BusinessError
          console.info("数据库版本从2版本升级到3版本失败 ==>", error.code, error.message)
        }
      }
      store.version = storeVersion
      // 确保获取到RdbStore实例，完成数据库表创建后，在进行数据库的增删改查等操作
    })


  }

  // 2、获取到RdbStore实例后，调用insert方法插入数据
  insertData(store: relationalStore.RdbStore){
    let value1 = "lisa", value2 = 18, value3 = 100.5, value4 = new Uint8Array([1,2,3,4]), value5 = BigInt("15822401018187971961171");
    const valueBucket: relationalStore.ValuesBucket = {
      NAME: value1,
      AGE: value2,
      SALARY: value3,
      CODES: value4,
      IDENTITY: value5
    }

    if (store !== undefined) {
      try {
        const rowId = store.insert("EMPLOYEE", valueBucket)
        console.info("数据插入成功 ==>", rowId)
      } catch (err) {
        const error = err as BusinessError
        console.error("数据插入失败 ==>", error.code, error.message)
      }
    }
  }

  // 3、调用update方法修改数据，根据谓词指定的实力对象，对数据进行修改或删除
  updateData(store: relationalStore.RdbStore){
    let value6 = 'Rose', value7 = 22,value8 = 200.5,value9 = new Uint8Array([1, 2, 3, 4, 5]),value10 = BigInt('15822401018187971967863');
    const valueBucket2: relationalStore.ValuesBucket = {
      NAME: value6,
      AGE: value7,
      SALARY: value8,
      CODES: value9,
      IDENTITY: value10,
    };
    // 创建表EMPLOYEE的predicates
    let predicates = new relationalStore.RdbPredicates("EMPLOYEE")
    // 添加修改条件
    predicates.equalTo("NAME", 'Lisa')
    // 更新数据
    if (store !== undefined) {
      store.update(valueBucket2, predicates, (err: BusinessError, rows: number) => {
        if (err) {
          console.info("数据修改失败 ==>", err.code, err.message)
        }else {
          console.info("数据修改成功 ==>", rows)
        }
      })
    }

    // 删除数据
    predicates = new relationalStore.RdbPredicates("EMPLOYEE")
    predicates.equalTo("NAME", "Rose")
    if (store !== undefined) {
      store.delete(predicates, (err, rows) => {
        if (err) {
          console.info("数据删除失败 ==>", err.code, err.message)
        }else {
          console.info("数据删除成功 ==>", rows)
        }
      })
    }
  }

  // 4、根据谓词查找数据，调用query方法查找数据，返回一个ResultSet结果集
  queryData(store: relationalStore.RdbStore) {
    const predicates = new relationalStore.RdbPredicates("EMPLOYEE")
    predicates.equalTo("NAME", "Lisa")
    if (store !== undefined) {
      store.query(predicates, (err: BusinessError, result: relationalStore.ResultSet) => {
        if (err) {
          console.info("数据查询失败 ==>", err.code, err.message)
        }else {
          console.info("数据查询成功 ==>", JSON.stringify(result))
          // result是一个数据集合的游标，默认指向第-1个记录，有效的数据从0开始
          while (result.goToNextRow()){
            const id = result.getLong(result.getColumnIndex("ID"))
            const name = result.getString(result.getColumnIndex("NAME"))
            const age = result.getLong(result.getColumnIndex("AGE"))
            const salary = result.getDouble(result.getColumnIndex("SALARY"))
            const identity = result.getValue(result.getColumnIndex("IDENTITY"))
            console.info(`row ==> id = ${id}, name = ${name}, age = ${age}, salary = ${salary}, identity = ${identity},}`)
          }
          // 释放数据集的内存空间
          result.close()
        }
      })
    }
  }

  // 5、关系型数据库还支持FTS全文检索，可以根据中文或者英文进行文本检索，针对中文分词器支持ICU分词
  async tokenizeData(store: relationalStore.RdbStore){
    const SQL_CREATE_TABLE = `CREATE TABLE IF NOT EXISTS example USING fts4(name, content, tokenize=icu zh_CN)`
    // 创建数据表
    try {
      await store.execute(SQL_CREATE_TABLE)
      console.info("数据库创建成功")
    }catch (err) {
      const error = err as BusinessError
      console.info("数据库表创建失败 ==>", error.code, error.message)
    }
    // 使用中文进行分词进行全文查找
    if (store !== undefined) {
      try {
        const resultSet = await store.querySql("SELECT name FROM example WHERE example MATCH ?", ['测试'])
        while ( resultSet.goToNextRow()) {
          const name = resultSet.getValue(resultSet.getColumnIndex("name"))
          console.info("获取到的用户名称 ==>", name)
        }
      }catch (err) {
        const error = err as BusinessError
        console.info("全文分词查询数据失败 ==>", error.code, error.message)
      }
     }
  }

  // 6、使用事务，调用createTransaction方法创建事务, 支持的事务类型有DEFERRED、IMMEDIATE和EXCLUSIVE，默认为DEFERRED
  async useTransaction(store: relationalStore.RdbStore){
    try {
      // 创建事务对象
      const transaction = await store.createTransaction({
        transactionType: relationalStore.TransactionType.DEFERRED, // 默认类型
      })
      try {

        // 使用事务对象插入数据
        const rowId = await transaction.insert("EMPLOYEE", {
          NAME: 'Lisa',
          AGE: 18,
          SALARY: 100.5,
          CODES: new Uint8Array([1, 2, 3, 4, 5])
        }, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)

        console.info("使用事务插入数据成功 ==>", rowId)

        // 使用事务对象更新数据
        const predicates = new relationalStore.RdbPredicates("EMPLOYEE")
        predicates.equalTo("NAME", "Lisa")
        const rows = await transaction.update({
          NAME: "Rose",
          AGE: 18,
          SALARY: 200.5,
          CODES:new Uint8Array([1,2,3,4,5])
        }, predicates, relationalStore.ConflictResolution.ON_CONFLICT_REPLACE)
        console.info("使用实物对象更新数据成功 ==>", rows)

        // 使用事务对象删除数据
        await transaction.execute("DELETE FROM EMPLOYEE WHERE age = ? or age = ?", [21, 20])
        console.info("使用事务对象删除数据成功")

        // 提交事务
        await transaction.commit()
        console.info("数据库事务提交成功")
      }catch (err) {
        const error = err as BusinessError
        // 事务回滚
        await transaction.rollback()
        console.info("数据库事务使用失败 ==>", error.code, error.message, "数据已回滚")
      }
    }catch (err) {
      const error = err as BusinessError
      console.info("数据库事务创建失败 ==>", error.code, error.message)
    }

  }

  // 7、手动备份数据库，调用backup方法进行备份
  backupDatabase(store: relationalStore.RdbStore){
    if (store !== undefined) {
      store.backup("backup.db", (err) => {
        if (err) {
          console.error("数据库备份失败 ==>", err.code, err.message)
        }else {
          console.info("数据库备份成功")
        }
      })
    }
  }

  // 8、手动从备份数据库中恢复数据，调用restore方法恢复
  restoreDatabase(store: relationalStore.RdbStore){
    if (store !== undefined) {
      store.restore("backup.db", (err: BusinessError) => {
        if (err) {
          console.info("数据库恢复失败 ==>", err.code, err.message)
        }else {
          console.info("数据库恢复成功")
        }
      })
    }
  }

  // 9、删除数据库，调用deleteRdbStore方法删除数据库
  deleteDatabase(store: relationalStore.RdbStore){
    relationalStore.deleteRdbStore(this.context, "RdbTest.db", (err) => {
      if (err) {
        console.error("数据库删除失败 ==>", err.code, err.message)
      }else {
        console.info("数据库删除成功")
      }
    })
  }

}
