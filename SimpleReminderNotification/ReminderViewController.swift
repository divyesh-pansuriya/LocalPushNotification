//    MIT License
//
//    Copyright (c) [2025] [Divyesh Pansuriya]
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

import Foundation
import UIKit
import UserNotifications

class ReminderViewController: UIViewController {
    
    // Randomly generated uuid as notificationId:
    // In order to keep track of multiple notifications we can generate
    // more uuids but for this particular one app we'll just use this
    let notificationId: String = UUID().uuidString
    var shouldSendToSettings: Bool = false
    var date: Date? = nil
    var notificationTitle: String {
        return titleTextView.text
    }
    var notificationBody: String {
        return descriptionTextView.text
    }
    var reminderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Title"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var reminderDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var reminderDateTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Date and Time"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var titleTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.text = ""
        textView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.textAlignment = .left
        textView.backgroundColor = UIColor(red: 0.94, green: 0.90, blue: 0.90, alpha: 1.00)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.text = ""
        textView.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        textView.textAlignment = .left
        textView.backgroundColor = UIColor(red: 0.94, green: 0.90, blue: 0.90, alpha: 1.00)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    var datePicker: UIDatePicker = {
        let picker : UIDatePicker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .dateAndTime
        picker.addTarget(self, action: #selector(dueDateChanged(sender:)), for: .allEditingEvents)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    lazy var rightAddNavButton: UIBarButtonItem = {
        let rightNavButton = UIBarButtonItem()
        rightNavButton.action = #selector(rightNavButtonAction)
        rightNavButton.target = self
        rightNavButton.title = "Save"
        return rightNavButton
    }()
    
    private lazy var registerNotificationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register local notificaion", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23, weight: .regular)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(registerLocalNotification), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var
        containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Manager
    var localNotificationManager = LocalNotificationManager()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // Setup
    private func setup() {
        // Background colour
        view.backgroundColor = .white
        
        // Navigation controller title
        self.navigationItem.title = "Reminder"
        
        // Navigation button
        self.navigationItem.rightBarButtonItem = rightAddNavButton
        
        // Dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)

        // Views
        view.addSubview(containerView)
        containerView.addSubview(reminderTitleLabel)
        containerView.addSubview(titleTextView)
        containerView.addSubview(reminderDescriptionLabel)
        containerView.addSubview(descriptionTextView)
        containerView.addSubview(reminderDateTimeLabel)
        containerView.addSubview(datePicker)
        view.addSubview(registerNotificationButton)
        
        checkIfRegistered()
        
        // Constraints
        let pickerSize : CGSize = datePicker.sizeThatFits(CGSize.zero)
        NSLayoutConstraint.activate([
            registerNotificationButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            registerNotificationButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            registerNotificationButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            registerNotificationButton.heightAnchor.constraint(equalToConstant: 40),
            
            containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            reminderTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            reminderTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            reminderTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            reminderTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),

            titleTextView.topAnchor.constraint(equalTo: reminderTitleLabel.bottomAnchor, constant: 5),
            titleTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),

            reminderDescriptionLabel.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 15),
            reminderDescriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            reminderDescriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 10),
            reminderDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),

            descriptionTextView.topAnchor.constraint(equalTo: reminderDescriptionLabel.bottomAnchor, constant: 5),
            descriptionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            descriptionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),

            datePicker.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 15),
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            descriptionTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: pickerSize.height),
            descriptionTextView.widthAnchor.constraint(greaterThanOrEqualToConstant: pickerSize.width),

            reminderDateTimeLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 15),
            reminderDateTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            reminderDateTimeLabel.trailingAnchor.constraint(equalTo: datePicker.trailingAnchor, constant: 0),
            reminderDateTimeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 25)
        ])
    }
    
    @objc func dueDateChanged(sender:UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        print(dateFormatter.string(from: sender.date))
        self.date = sender.date
    }
    
    //MARK: Navigation button actions
    @objc private func rightNavButtonAction() {
        let alert = UIAlertController(title: "Reminder confirmation", message: "Save push notification", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: {
            action in
            guard let date = self.date else {
                print("Error: No date to set the reminder")
                return
            }
            self.scheduleLocal(title: self.notificationTitle, body: self.notificationBody, id: self.notificationId, date: date)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Notification
    func checkIfRegistered() {
        localNotificationManager.checkIfRegistered { permission in
            DispatchQueue.main.async {
                switch permission {
                case .authorized:
                    self.registerNotificationButton.isHidden = true
                    self.containerView.isHidden = false
                case .denied:
                    self.registerNotificationButton.isHidden = false
                    self.containerView.isHidden = true
                    self.shouldSendToSettings = true
                case .notAsked:
                    self.registerNotificationButton.isHidden = false
                    self.containerView.isHidden = true
                default:
                    self.registerNotificationButton.isHidden = false
                    self.containerView.isHidden = true
                    self.shouldSendToSettings = true
                }
            }
        }
    }
    
    @objc func registerLocalNotification() {
        guard !shouldSendToSettings else {
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
            return
        }
        // Ask for permission
        localNotificationManager.registerLocal { (granted, error) in
            guard error == nil else {
                print("error \(error.debugDescription)")
                return
            }
            if granted {
                print("Authorization granted!!")
            } else {
                print("Authorization denied!!")
            }
            self.checkIfRegistered()
        }
    }
    
    @objc func scheduleLocal(title: String, body: String, id: String, date: Date) {
        localNotificationManager.schedule(title: title, body: body, id: id, date: date)
    }
}
