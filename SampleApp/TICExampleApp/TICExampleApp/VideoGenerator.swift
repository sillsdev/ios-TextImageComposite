//
//  VideoGenerator.swift
//  TICExampleApp
//
//  Created by hubbard on 1/25/21.
//

import Foundation
import UIKit
import TextImageComposite
import mobileffmpeg

class VideoGenerator: SharingDelegate {
    func createVideo(config: TICConfig, image: UIImage, completionHandler: @escaping TICShareCompletionHandlerType) -> Bool {
        let delayTime = DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            if let data = image.jpegData(compressionQuality: 1.0) {
                let imageURL = getCreateSupportDirectory("audio", excludeFromBackup: true)!.appendingPathComponent("image.png")
                try? data.write(to: imageURL)
                if let videoFilename = self.generateVideo(TICConfig.instance, imageURL.path) {
                    NSLog("video: \(String(describing: videoFilename))")
                    completionHandler(true, URL(fileURLWithPath: videoFilename))
                }
            }
            
            completionHandler(false, nil)
        }
        return true
    }
    
    func generateVideo(_ config: TICConfig, _ imageFilename: String) -> String? {
        let outputFilename = "Genesis-1.1.mp4"
        let videoURL = getCreateSupportDirectory("video", excludeFromBackup:true)!.appendingPathComponent(outputFilename)
        let audioURL = Bundle.main.url(forResource: "Genesis-1.1.mp3", withExtension: "")!
        let cmd = "-y -framerate 2 -loop 1 -i \"\(imageFilename)\" -i \"\(audioURL.path)\" -map_metadata 0 -acodec aac -write_xing 0 -vcodec mpeg4 -preset veryfast -tune stillimage -pix_fmt yuv420p -qscale:v 4 -r 24 -shortest \"\(videoURL.path)\""
        let result = MobileFFmpeg.execute(cmd)
        NSLog("result=\(result)")
        return result == 0 ? videoURL.path : nil
    }
    
}
