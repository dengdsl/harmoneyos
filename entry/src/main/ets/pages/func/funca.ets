@Entry
@Component
struct FuncA {
  build() {
    Column(){
      Text("这个页面用于接收Index页面传递过来的数据").fontSize(20).fontColor("#10b8a9").padding(10).margin({
        top: 30
      })

      Button("点击我携带数据返回").type(ButtonType.Normal).borderRadius(6).margin({
        top: 100
      }).onClick(() => {
        console.log("这里需要处理返回到上一个页面的数据")
      })
    }.backgroundColor("#f5f5f5").width("100%").height("100%")
  }
}