//
//  Debouncer.swift
//  SearchExplore
//
//  Created by Francesco Leoni on 22/09/22.
//

import Foundation

public class Debouncer {
  
  private let timeInterval: TimeInterval
  private var timer: Timer?
  private var handler: (() -> Void)?
  
  init(timeInterval: TimeInterval) {
    self.timeInterval = timeInterval
  }
  
  public func perform(_ action: @escaping () -> Void) {
    handler = action
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] (timer) in
      self?.timeIntervalDidFinish(for: timer)
    })
  }
  
  public func cancel() {
    handler = nil
    timer?.invalidate()
  }
  
  @objc private func timeIntervalDidFinish(for timer: Timer) {
    guard timer.isValid else {
      return
    }
    
    handler?()
    handler = nil
  }
}
