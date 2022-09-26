//
//  DetailsVC.swift
//  SearchExplore
//
//  Created by Francesco Leoni on 21/09/22.
//

import UIKit

class DetailsVC: UIViewController {
  
  init(text: String) {
    super.init(nibName: nil, bundle: nil)
    self.title = text
    self.view.backgroundColor = .white
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
