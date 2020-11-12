## DevOps

SSH in to the DigitalOcean server.

```
// username: soundblab
// password: blab@123#
// ssh_access:
$ ssh soundblab@craftacademy.se

// Make sure ssh public key is added to server
```

root directory: `/var/www/html/ca-certificates`



## ImageMagick issues
install_name_tool -change \
    /ImageMagick-7.0.10-37/lib/libMagickCore-7.Q16HDRI.6.dylib \
    @executable_path/../lib/libMagickCore-7.Q16HDRI.6.dylib \
    /Users/thomas_ochman/ImageMagick/bin/magick

# magick: set the correct path to libMagickWand.dylib
install_name_tool -change \
    /ImageMagick-7.0.10-37/lib/libMagickWand-7.Q16HDRI.6.dylib \
    @executable_path/../lib/libMagickWand-7.Q16HDRI.6.dylib \
    /Users/thomas_ochman/ImageMagick-7.0.8/bin/magick

# libMagickWand.dylib: set the correct ID
install_name_tool -id \
    @executable_path/../lib/libMagickWand-7.Q16HDRI.6.dylib \
    /Users/thomas_ochman/ImageMagick-7.0.8/lib/libMagickWand-7.Q16HDRI.6.dylib

# libMagickWand.dylib: set the correct path
install_name_tool -change \
    /ImageMagick-7.0.8/lib/libMagickCore-7.Q16HDRI.6.dylib \
    @executable_path/../lib/libMagickCore-7.Q16HDRI.6.dylib \
    /Users/thomas_ochman/ImageMagick-7.0.8/lib/libMagickWand-7.Q16HDRI.6.dylib

# libMagickCore.dylib: set the correct ID
install_name_tool -id \
    @executable_path/../lib/libMagickCore-7.Q16HDRI.6.dylib \
    /Users/thomas_ochman/ImageMagick-7.0.8/lib/libMagickCore-7.Q16HDRI.6.dylib