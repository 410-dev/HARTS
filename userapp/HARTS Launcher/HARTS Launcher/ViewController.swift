//
//  ViewController.swift
//  HARTS Launcher
//
//  Created by Hoyoun Song on 2020/07/17.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let ROOT = "/tmp/HARTS/"
        let OrtaOS_ParentDMGMntPoint = ROOT + "ortaos/venv"
        let OrtaOS_Vrootfs = ROOT + "ortaos/vrootfs/"
        let OrtaOS_Signing = "https://raw.githubusercontent.com/cfi3288/HARTS-Signing-Server/master/sgType1/orta512"
        
        NSSwiftUtils.createDirectoryWithParentsDirectories(to: OrtaOS_Vrootfs + "System")
        NSSwiftUtils.createDirectoryWithParentsDirectories(to: OrtaOS_ParentDMGMntPoint)
        NSSwiftUtils.executeShellScript("hdiutil", "attach", Bundle.main.resourcePath! + "/venv.dmg", "-mountpoint", OrtaOS_ParentDMGMntPoint)
        NSSwiftUtils.executeShellScript(Bundle.main.resourcePath! + "/shasum", OrtaOS_ParentDMGMntPoint + "/venv.dmg", ROOT + "thisshasum")
        NSSwiftUtils.executeShellScript("curl", "-Ls", OrtaOS_Signing, "-o", ROOT + "remoteshasum")
        let RemoteShasum = NSSwiftUtils.readContents(of: ROOT + "remoteshasum")
        print("Remote Checksum: " + RemoteShasum)
        let LocalShasum = NSSwiftUtils.readContents(of: ROOT + "thisshasum").components(separatedBy: " ")[0]
        NSSwiftUtils.deleteFile(at: ROOT + "thisshasum")
        NSSwiftUtils.deleteFile(at: ROOT + "remoteshasum")
        print("Local Checksum: " + LocalShasum)
        if RemoteShasum.elementsEqual(LocalShasum) || CommandLine.arguments.joined().contains("debug") {
            NSSwiftUtils.executeShellScript("hdiutil", "attach", OrtaOS_ParentDMGMntPoint + "/venv.dmg", "-mountpoint", OrtaOS_Vrootfs + "System")
            if CommandLine.arguments.joined().contains("debug") {
                NSSwiftUtils.writeData(to: ROOT + "/bootarg", content: "NO_SIGNING NO_VM_DETECTION")
            }
            NSSwiftUtils.executeShellScript(Bundle.main.resourcePath! + "/async-start", OrtaOS_Vrootfs + "System/boot/init")
            while true {
                if NSSwiftUtils.doesTheFileExist(at: OrtaOS_Vrootfs + "/emulated/0/bootdone") {
                    break
                }else if NSSwiftUtils.doesTheFileExist(at: ROOT + "orta-error"){
                    print("ERROR while starting OrtaOS: " + NSSwiftUtils.readContents(of: ROOT + "orta-error"))
                    let Graphics: GraphicComponents = GraphicComponents()
                    Graphics.messageBox_errorMessage(title: "Runtime Error", contents: "Unable to start security layer.\nOutput from agent: \(NSSwiftUtils.readContents(of: ROOT + "orta-error"))")
                    NSSwiftUtils.executeShellScript("hdiutil", "detach", OrtaOS_ParentDMGMntPoint, "-force")
                    NSSwiftUtils.removeDirectory(at: ROOT, ignoreSubContents: true)
                    break
                }else if NSSwiftUtils.doesTheFileExist(at: OrtaOS_Vrootfs + "/emulated/0/depinstall") {
                    AppDelegate.showNotification(title: "Installing Packages", subtitle: "HARTS is installing dependency packages. This may take a while.", informativeText: "")
                    NSSwiftUtils.executeShellScript("rm", "-f", OrtaOS_Vrootfs + "/emulated/0/depinstall")
                }
            }
            exit(0)
        }else{
            let Graphics: GraphicComponents = GraphicComponents()
            Graphics.messageBox_errorMessage(title: "Modified software", contents: "Unable to prepare virtual environment for safe test, because the software seems to be modified.")
            NSSwiftUtils.executeShellScript("hdiutil", "detach", OrtaOS_ParentDMGMntPoint, "-force")
            exit(0)
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

