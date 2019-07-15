# AVCaptureMetadataOutput + （OpenCV + Zxing）

## 这是一款二维码扫描的解决方案。

iOS端扫描二维码无非是苹果提供的AVCaptureMetadataOutput系列、Zxing、Zbar。而Zbar早已不在维护，我们不打算再使用（Android现在还在使用Zbar）。
   
所以本方案是基于AVCaptureMetadataOutput + Zxing共同实现的，当然这两个网上例子一大堆，可是像本项目这样好用的就没有了。 

## 为何这样做
为何用到Zxing，事实上Zxing确实扫描能力不如AVCaptureMetadataOutput，目前苹果的扫码器能满足大部分场景，但是不是所有的二维码都是完美的。

比如

  1、有些二维码是打印出来的颜色变成了灰色（因手里的异常二维码属于公司私有不能拿出来）。
  
  2、扫描受到光照的影响。
  
  3、斜扫二维码
 
## OpenCV

在二维码识别之前如果有一种技术能把异常的二维码处理成高清的那就好了，此时OpenCV就上场了，由于二维码识别不在乎颜色，那么图片二值化就是我们首先想到的了，能把灰色的像素点处理成黑色那相信二维码识别器就能较高成功率的识别， 

这里OpenCV就做了 降噪 + 图片二值化的工作。 

由于苹果的API太过于封闭，我不知道怎么单独调用苹果的扫描，所以这里就使用到了Zxing来做接盘侠。 当然苹果的二维码识别器我们也没浪费。

Cocoapods 使用 

``` 
pod 'JDScan'

```

如果你是一名Android开发 https://github.com/LiuhangZhang/qrcode_android 这里是Android的解决方案，本方案一开始使用的整体二值化不是太理想，后面借鉴此项目中分块二值化效果还不错，毕竟本人OpenCV知识也是有限。

本方案也不是万能的，当然足够满足大部分企业需求，如果需要做成微信那样，可能就需要使用OCR技术了。
