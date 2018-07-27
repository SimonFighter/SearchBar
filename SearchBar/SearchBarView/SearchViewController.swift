//
//  SearchViewController.swift
//  SearchBar
//
//  Created by huangmian on 2018/7/26.
//  Copyright © 2018年 hm. All rights reserved.
//

import UIKit
import SwifterSwift

class SearchViewController: UIViewController {
    
    @IBOutlet weak var resultTableView: UITableView!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var relativeTableView: UITableView!
    
    let viewModel = SearchViewModel()
    var historyList = [String]()
    let searchBarView = SearchBarView.init(frame: CGRect.zero)
    
    var searchString = ""
    
    
    private var playSoundFromHere = false
    
    var popRecognizer: InteractivePopRecognizer?
    
    static var storyBoardName: String {
        return "Search"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configNavigationBar()
        setupViews()
        loadData()
        setInteractiveRecognizer()
    }
    
    func configNavigationBar() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
        searchBarView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 30, height: 30)
        self.navigationItem.titleView = searchBarView;
        searchBarView.delegate = self
        searchBarView.hideKeyboard(false)
        navigationController?.navigationBar.tintColor = UIColor.init(hexString: "#494949")
        navigationController?.navigationBar.backIndicatorImage = #imageLiteral(resourceName: "icon_back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "icon_back")
        self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    }
    
    func setupViews() {
        if #available(iOS 11.0, *) {
            historyTableView.contentInsetAdjustmentBehavior = .never
            relativeTableView.contentInsetAdjustmentBehavior = .never
            resultTableView.contentInsetAdjustmentBehavior = .never
        }else{
            automaticallyAdjustsScrollViewInsets = false
        }
        
        historyTableView.isHidden = false
        resultTableView.isHidden = true
        relativeTableView.isHidden = true
        
        resultTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        resultTableView.backgroundColor = UIColor.white
        resultTableView.register(cellWithClass: SearchResultCell.self)
        
        historyTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        historyTableView.register(cellWithClass: SearchHistoryTitleCell.self)
        historyTableView.register(cellWithClass: SearchHistoryCell.self)
        
        relativeTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        relativeTableView.register(cellWithClass: SearchRelativeCell.self)
    }
    
    func loadData() {
        self.historyList = viewModel.getSearchHistory()
    }
    
    func searchAction(_ searchString: String){
        print("searchString \(searchString)")
        let searchText = searchString.trimmingCharacters(in: CharacterSet.whitespaces)
        if searchString.count > 0 && !(searchText.count > 0) {
            print("请输入歌曲、歌手或专辑名称")
            searchBarView.setSearchTextString(searchTextString: "")
            return
        }
        if !(searchText.count > 0) {
            print("请输入你要搜索的内容")
            return
        }
        searchBarView.hideKeyboard(true)
        if let index = self.historyList.index(of: searchText) {
            self.historyList.remove(at: index)
            self.historyList.insert(searchText, at: 0)
        }else{
            self.historyList.insert(searchText, at: 0)
        }
        viewModel.saveSearchHistory(histroys: self.historyList)
        historyTableView.reloadData()
        
        relativeTableView.reloadData()
        resultTableView.reloadData()
        historyTableView.isHidden = true
        resultTableView.isHidden = false
        relativeTableView.isHidden = true
        print("正在搜索“\(searchText)”")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage.init(color: UIColor.init(hexString: "#000000", alpha: 0.08),
                                                                            size: CGSize(width: 1, height: 1))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if historyTableView.isHidden == false {
            searchBarView.hideKeyboard(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage.init()
        searchBarView.hideKeyboard(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    deinit {
        print("SearchViewController deinit")
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBarView.hideKeyboard(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == historyTableView {
            if self.historyList.count > 0 {
                return self.historyList.count + 1
            }
            return 0
        }else if tableView == resultTableView {
            return 10
        }else if tableView == relativeTableView {
            return 1
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == historyTableView {
            
            if indexPath.row == 0 {
                return 64.0
                
            }else{
                return 45.0
            }
            
        }else if tableView == resultTableView {
            return 115.0
            
        }else if tableView == relativeTableView {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == historyTableView {
            
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withClass: SearchHistoryTitleCell.self)
                cell.cleanTapped = { [weak self] in
                self?.showAlert("是否清空所有搜索历史", "取消", "清空", UIColor.init(hexString: "#494949"), UIColor.init(hexString: "#494949"),
                                       callback1: {
                                        print("取消")

                }, callback2: {
                    print("清空")
                    self?.historyList.removeAll()
                    self?.viewModel.clearSearchHistory()
                    tableView.reloadData()

                })
                }
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withClass: SearchHistoryCell.self)
                cell.setTitle(titleString: self.historyList[indexPath.row - 1])
                cell.deleteTapped = { [weak self] in
                    self?.historyList.remove(at: indexPath.row - 1)
                    self?.viewModel.saveSearchHistory(histroys: self?.historyList ?? [String]())
                    tableView.reloadData()
                }
                return cell
            }
        }else if tableView == resultTableView {
            let cell = tableView.dequeueReusableCell(withClass: SearchResultCell.self)
            cell.setName("周杰伦")
            cell.setAvartar("jielun.jpg")
            return cell
        }else if tableView == relativeTableView {
            let cell = tableView.dequeueReusableCell(withClass: SearchRelativeCell.self)
            cell.setSearchText(searchText: searchString)
            return cell
        }
        return UITableViewCell.init()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView == historyTableView {
            if indexPath.row == 0 {
                
            }else {
                let historyString = self.historyList[indexPath.row - 1]
                searchString = historyString
                searchBarView.setSearchTextString(searchTextString: historyString)
                searchAction(searchString)
            }
        }else if tableView == resultTableView {
            let searchDetailVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultDetailViewController")
            self.navigationController?.pushViewController(searchDetailVC, animated: true)
            
        }else if tableView == relativeTableView {
            searchAction(searchString)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension SearchViewController: SearchBarViewDelegate {
    func SearchBarViewcancelAction() {
        print("cancelAction")
        searchBarView.hideKeyboard(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func SearchBarViewEditingChanged(textField: UITextField) {
        searchString = textField.text ?? ""
        if textField.text?.count == 0 {
            historyTableView.isHidden = false
            relativeTableView.isHidden = true
            resultTableView.isHidden = true
        }else{
            historyTableView.isHidden = true
            relativeTableView.isHidden = false
            resultTableView.isHidden = true
            relativeTableView.reloadData()
        }
    }
    
    func SearchBarViewSearchAction(textField: UITextField) {
        print("searchAction")
        searchAction(textField.text ?? "")
    }
    
    func SearchBarViewDidBeginEditing(textField: UITextField) {
        textField.text = searchString
        if textField.text?.count == 0 {
            historyTableView.isHidden = false
            relativeTableView.isHidden = true
            resultTableView.isHidden = true
        }else{
            historyTableView.isHidden = true
            relativeTableView.isHidden = false
            resultTableView.isHidden = true
        }
    }
}


extension SearchViewController {
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
}

extension SearchViewController {
    private func showAlert(_ msg: String?, _ button1TitleString: String?, _ button2TitleString: String?, _ color1: UIColor, _ color2: UIColor, callback1:@escaping ()->Void, callback2: @escaping ()->Void) {
        let attributedString = NSAttributedString(string: msg ?? "", attributes: [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17),
            NSAttributedStringKey.foregroundColor : UIColor.init(hexString: "#000000") ?? ""
            ])
        
        let alert = UIAlertController(title:nil , message: nil, preferredStyle: .alert)
        if #available(iOS 8.3, *) {
            alert.setValue(attributedString, forKey: "attributedTitle")
        }
        
        if let button1TitleString = button1TitleString {
            let action1 = UIAlertAction(title: button1TitleString , style: .default, handler: { (action) in
                callback1()
            })
            action1.setValue(color1, forKey: "titleTextColor")
            alert.addAction(action1)
        }
        
        if let button2TitleString = button2TitleString {
            let action2 = UIAlertAction(title: button2TitleString , style: .default, handler: { (action) in
                callback2()
            })
            action2.setValue(color2, forKey: "titleTextColor")
            alert.addAction(action2)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

class InteractivePopRecognizer: NSObject, UIGestureRecognizerDelegate {
    
    weak var navigationController: UINavigationController?
    
    init(controller: UINavigationController) {
        self.navigationController = controller
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = navigationController else {return false}
        return navigationController.viewControllers.count > 1
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
