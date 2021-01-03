//
//  NewsFeedView.swift
//  StoriesNewsFeed
//
//  Created by Tomas Martins on 28/12/20.
//

import UIKit

public class StoryFeedView: UIView {
    //MARK: - Components
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var headlineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var progressStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.contentMode = .scaleToFill
        return stackView
    }()
    
    private var gradient = CAGradientLayer()
    private var gradientView = UIView()
    
    private var progressBarAnimator = UIViewPropertyAnimator()
    private var gradientAnimator = UIViewPropertyAnimator()
    private var headlineAnimator = UIViewPropertyAnimator()
    private var imageViewAnimator = UIViewPropertyAnimator()
    
    //MARK: - Properties
    var viewModel = StoryFeedViewModel()
    
    private var progressViews: [UIProgressView] {
        get {
            var bars = [UIProgressView]()
            progressStackView.subviews.forEach {
                if let bar =  $0 as? UIProgressView {
                    bars.append(bar)
                }
            }
            return bars
        }
    }
    
    /// Story to be displayed
    public var story: Story? {
        didSet {
            resetAnimations()
        }
    }
    
    /// The amount of stories to be displayed
    public var amount: Int? {
        didSet {
            removeBars()
            guard let amount = amount else { return }
            viewModel.amount = amount
            for _ in 0 ..< amount {
                let bar = newProgressBar()
                bar.translatesAutoresizingMaskIntoConstraints = false
                progressStackView.addArrangedSubview(bar)
            }
        }
    }
    
    /// The UIFont to be used by the headline label
    public var font: UIFont? {
        didSet {
            headlineLabel.font = font
        }
    }
    
    /// Tint color of the progress bar
    public var tint: UIColor? {
        didSet {
            progressStackView.subviews.forEach {
                if let bar =  $0 as? UIProgressView {
                    bar.progressTintColor = tint
                }
            }
        }
    }
    
    /// Amount of time (in seconds) until the feed moves to the next story automatically. The default time is 5 seconds
    public var timeLimit: Double = 5.0 {
        didSet {
            progressBarAnimator.addCompletion { _ in
                if self.viewModel.isOverlappingIndex(isIncreasing: true) {
                    self.resetProgress()
                } else {
                    self.fillBars(upTo: self.viewModel.currentIndex())
                }
                self.timerAction()
            }
            resetAnimations()
        }
    }
    
    //MARK: - Actions
    /// Action that is executed when the left side of the view is tapped
    public var leftTapAction: (() -> ())? {
        didSet {
            setupGestures()
        }
    }
    
    /// Action that is executed when the right side of the view is tapped
    public var rightTapAction: (() -> ())? {
        didSet {
            setupGestures()
        }
    }
    
    /// Action that is executed when the view detects a long press
    public var longPressAction: (() -> ())? {
        didSet {
            setupGestures()
        }
    }
    
    /// Action that is executed when the view is released after a long press
    public var releaseLongPressAction: (() -> ())? {
        didSet {
            setupGestures()
        }
    }
    
    /// Action that is executed when the headline label is tapped
    public var headlineAction: (() -> ())? {
        didSet {
            self.headlineLabel.isUserInteractionEnabled = true
            let action = UITapGestureRecognizer(target: self, action: #selector(labelAction))
            self.headlineLabel.addGestureRecognizer(action)
        }
    }
    
    /// Action that is executed when the current timer ends
    public var timerDidEnd: (() -> ())?
    
    //MARK: - Initializers
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupComponents()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupComponents()
        setupGestures()
    }
    
    //MARK: - Methods
    /// Manually move to a specific index and story
    public func moveTo(index: Int, story: Story?) {
        self.stopAnimations()
        viewModel.setIndex(index)
        self.story = story
    }
    
    private func resetAnimations() {
        stopAnimations()
        self.headlineLabel.alpha = 0.0
        self.imageViewAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
            UIView.transition(with: self.imageView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = self.story?.image },
                              completion: nil)
        })
        imageViewAnimator.addCompletion { _ in
            self.headlineLabel.text = self.story?.headline
            self.startProgress(for: self.progressViews[self.viewModel.currentIndex()])
            self.headlineAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
                self.headlineLabel.alpha = 1.0
            })
            self.headlineAnimator.startAnimation()
        }
        self.imageViewAnimator.startAnimation()
    }
    
    private func stopAnimations() {
        self.progressBarAnimator.stopAnimation(true)
        self.headlineAnimator.stopAnimation(true)
        self.imageViewAnimator.stopAnimation(true)
    }
    
    private func removeBars() {
        self.progressStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

//MARK: - Gestures
extension StoryFeedView {
    //Setup methods
    private func setupGestures() {
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(executeTap))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        addGestureRecognizer(tapGestureRecongnizer)
        addGestureRecognizer(longPressRecognizer)
    }

    @objc private func executeTap(tap: UITapGestureRecognizer) {
        let point = tap.location(in: self)
        let leftArea = CGRect(x: 0, y: 0, width: bounds.width/4, height: bounds.height)
        let rightArea = CGRect(x: bounds.width, y: 0, width: -bounds.width/4, height: bounds.height)
        if leftArea.contains(point) {
            leftAction()
        } else if rightArea.contains(point) {
            rightAction()
        }
    }
    
    @objc private func longPressed(sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            holdAction()
        }
        if sender.state == .ended {
            releaseAction()
        }
    }
    
    //Action Methods
    @objc private func leftAction() {
        self.stopAnimations()
        if viewModel.isOverlappingIndex(isIncreasing: false) {
            fillBars(upTo: viewModel.previousIndex()-1)
        } else {
            self.progressViews[self.viewModel.currentIndex()].setProgress(0.0, animated: false)
            self.progressViews[self.viewModel.previousIndex()].setProgress(0.0, animated: false)
        }
        viewModel.decreaseIndex()
        self.leftTapAction?()
    }
    
    @objc private func rightAction() {
            self.stopAnimations()
            if viewModel.isOverlappingIndex(isIncreasing: true) {
                resetProgress()
            } else {
                self.fillBars(upTo: viewModel.currentIndex())
            }
            viewModel.increaseIndex()
            self.rightTapAction?()
        }
    
    @objc private func holdAction() {
        progressBarAnimator.pauseAnimation()
        self.longPressAction?()
    }
    
    @objc private func releaseAction() {
        progressBarAnimator.startAnimation()
        self.releaseLongPressAction?()
    }
    
    @objc private func labelAction() {
        self.headlineAction?()
    }
    
    @objc private func timerAction() {
        if viewModel.isOverlappingIndex(isIncreasing: true) {
            resetProgress()
        } else {
            self.progressViews[self.viewModel.currentIndex()].setProgress(1.0, animated: false)
        }
        viewModel.increaseIndex()
        self.timerDidEnd?()
    }
}

//MARK: - Progress Bar
extension StoryFeedView {
    private func resetProgress() {
        self.progressStackView.subviews.forEach {
            if let bar =  $0 as? UIProgressView {
                bar.setProgress(0.0, animated: false)
            }
        }
    }
    
    private func fillBars(upTo position: Int) {
        for index in 0 ... position {
            self.progressViews[index].setProgress(1.0, animated: false)
        }
    }
    
    private func newProgressBar() -> UIProgressView {
        let progressView = UIProgressView(progressViewStyle: .default)
        if #available(iOS 13, *) {
            progressView.backgroundColor = UIColor.systemGray3
        } else {
            progressView.backgroundColor = UIColor.lightGray
        }
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 2.0
        progressView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        progressView.tintColor = self.tint
        return progressView
    }
    
    private func startProgress(for progressView: UIProgressView) {
        progressBarAnimator = UIViewPropertyAnimator(duration: timeLimit, curve: .linear, animations: {
            progressView.setProgress(1.0, animated: true)
        })
        progressBarAnimator.addCompletion { _ in
            progressView.setProgress(0.0, animated: false)
            self.timerAction()
        }
        progressBarAnimator.startAnimation()
    }
}

//MARK: - UI Setup
extension StoryFeedView {
    private func setupComponents() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        self.gradientView.translatesAutoresizingMaskIntoConstraints = false
        self.progressStackView.translatesAutoresizingMaskIntoConstraints = false
        
        setupGradient()
        
        self.addSubview(imageView)
        self.addSubview(gradientView)
        self.addSubview(headlineLabel)
        self.addSubview(progressStackView)
        
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            self.gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            self.gradientView.heightAnchor.constraint(equalToConstant: self.bounds.height/3),
            self.headlineLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            self.headlineLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.headlineLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            self.progressStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 6),
            self.progressStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            self.progressStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            self.progressStackView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setupGradient() {
        self.gradientView.alpha = 0.0
        if #available(iOS 13, *) {
            gradient.colors = [
                UIColor.clear.cgColor,
                UIColor.systemBackground.resolvedColor(with: .current).withAlphaComponent(0.2).cgColor,
                UIColor.systemBackground.resolvedColor(with: .current).withAlphaComponent(0.8).cgColor,
                UIColor.systemBackground.resolvedColor(with: .current).cgColor
            ]
        } else {
            gradient.colors = [
                UIColor.clear.cgColor,
                UIColor.white.withAlphaComponent(0.2).cgColor,
                UIColor.white.withAlphaComponent(0.8).cgColor,
                UIColor.white.cgColor
            ]
        }
        gradient.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/3)
        gradientView.layer.insertSublayer(gradient, at:0)
        gradientAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
            self.gradientView.alpha = 1.0
        })
        gradientAnimator.startAnimation()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupGradient()
    }
}
