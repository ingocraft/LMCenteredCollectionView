//
//  MainViewController.swift
//  LMCenteredCollectionView-Example
//
//  Created by Liam on 2019/3/7.
//  Copyright © 2019 Liam. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
