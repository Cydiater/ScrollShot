//
//  ContentView.swift
//  Shared
//
//  Created by Cydiater on 2021/9/17.
//

import SwiftUI
import UIKit

extension UIView {
    var screenShot: UIImage {
        let rect = self.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: context)
        let capturedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return capturedImage
    }
}

extension View {
    func takeScreenshot(origin: CGPoint, size: CGSize) -> UIImage {
        let hosting = UIHostingController(rootView: self)
        let window = UIWindow(frame: CGRect(origin: origin, size: size))
        hosting.view.frame = window.frame
        window.addSubview(hosting.view)
        window.makeKeyAndVisible()
        return hosting.view.screenShot
    }
}

struct Item: Identifiable {
    let id: Int
    let color: Color
    
    static var samples = [Item(id: 1, color: Color.red), Item(id: 2, color: Color.blue), Item(id: 3, color: Color.purple)]
}

struct InternalContent: View {
    @Binding var items: [Item]
    @Binding var snapshot: Bool
    
    var body: some View {
        ForEach(items) { item in
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(item.color)
                    .frame(height: 100)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                Text("No. " + String(item.id))
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
            }
        }
        .padding()
        .background(ZStack {
            GeometryReader { proxy in
                Color.clear.onChange(of: snapshot) { (newVal) in
                    if newVal {
                        let origin = proxy.frame(in: .global).origin
                        print(origin)
                        let image = self.takeScreenshot(origin: origin, size: proxy.size)
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        snapshot.toggle()
                    }
                }
            }
        })
    }
}

struct ContentView: View {
    
    @State private var items = Item.samples
    @State private var snapshot = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                InternalContent(items: $items, snapshot: $snapshot)
            }
            .navigationBarTitle("ScrollShot", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                snapshot.toggle()
            }) { Image(systemName: "camera") }, trailing: Button(action: {
                let new = Item(id: items.count + 1, color: [Color.red, Color.blue, Color.purple, Color.green].randomElement()!)
                items.append(new)
            }) {
                Image(systemName: "plus")
            })
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
