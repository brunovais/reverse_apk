def listPackages(name)
    print(%x(adb shell pm list packages | grep #{name}))
end

def getPathByPackageName(package)
    %x(adb shell pm path #{package})
end

def getAppByPath(paths)
    path = paths.split("apk")[0] + "apk"
    pathFinal = path.split("package:")[1]
    %x(adb pull #{pathFinal})
end

def unpackageApk
    %x(apktool d base.apk)
end

def getAndroidManifest
    fullManifestPath = File.expand_path('reverse.rb').split("reverse.rb")[0] + "base/AndroidManifest.xml"
    %x(cat #{fullManifestPath})
end

def getEntryPoint(manifest)
    partOne = manifest.split("android.intent.category.LAUNCHER")[0]
    partTwo = partOne.split("<activity android:")[1]
    partThree = partTwo.split("android:name=\"")[1]
    entryPoint = partThree.split("\" android:")[0]
    print(entryPoint)
end

def turnDebuggable(manifest, package)
    partOne = manifest.split("<application ")[0]
    partTwo = manifest.split("<application ")[1]
    final = + partOne + '<application android:debuggable="true" ' + partTwo
    File.write(File.expand_path('reverse.rb').split("reverse.rb")[0] + "base/AndroidManifest.xml", final)
    print("TAG DEBUGGABLE INJECTED!")
    %x(rm fucked.apk)
    print("COMPILING DEBUGGABLE APK")
    %x(apktool b base -o fucked.apk)
    print("ASSING APK")
    #achar como pegar caminho absoluto
    %x(/Users/brunosampaio/Library/Android/sdk/build-tools/33.0.0/apksigner sign --ks fuck.keystore --ks-pass file:my-passfile.txt --v1-signing-enabled true --v2-signing-enabled true fucked.apk)
    print("UNINSTALLING OLD APK")
    %x(adb uninstall #{package})
    print("INSTALLING APK")
    %x(adb install -r -t fucked.apk)
end

def reverseByPackage(package, isDebuggable)
    print("indentificando caminho do aplicativo\n")
    paths = getPathByPackageName(package)
    print("clonando aplicativo\n")
    print(getAppByPath(paths))
    print("desempacotando aplicativo\n")
    print(unpackageApk())
    manifest = getAndroidManifest()
    if isDebuggable
        turnDebuggable(manifest, package)
    end
    if !isDebuggable
        entryPoint = getEntryPoint(manifest)
    end
end

def printOptions
    print("reverse aplication\n")
    print("-p to get entrypoint by packagename\n")
    print("-n to get package name that cotains the name\n")
    print("-d turn the apk debuggable by package name example reverse_apk.rb -d com.oxxy.app")
end

for i in 0 ... ARGV.length
    if ARGV[i] == "-h"
        printOptions()
    end
    if ARGV[i] == "-p"
        reverseByPackage(ARGV[i + 1], false)
    end
    if ARGV[i] == "-n"
        listPackages(ARGV[i + 1])
    end
    if ARGV[i] == "-d"
        reverseByPackage(ARGV[i + 1], true)
    end
end