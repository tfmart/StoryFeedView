//
//  NewsFeedView.swift
//  StoriesNewsFeed
//
//  Created by Tomas Martins on 28/12/20.
//

import UIKit

public class StoryFeedView: UIView {
    //MARK: - Components
    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    internal lazy var headlineLabel: UILabel = {
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
    
    internal var progressBarAnimator = UIViewPropertyAnimator()
    internal var headlineAnimator = UIViewPropertyAnimator()
    internal var imageViewAnimator = UIViewPropertyAnimator()
    
    //MARK: - Properties
    internal var viewModel = StoryFeedViewModel()
    
    internal var progressViews: [UIProgressView] {
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
    
    /// The UIFont to be used by the headline label
    public var font: UIFont? {
        didSet {
            headlineLabel.font = font
        }
    }
    
    /// Tint color of the progress bar
    public var progressTintColor: UIColor? {
        didSet {
            progressStackView.subviews.forEach {
                if let bar =  $0 as? UIProgressView {
                    bar.progressTintColor = progressTintColor
                }
            }
        }
    }
    
    //MARK: - Actions
    /// Action that is executed when the left side of the view is tapped
    public var leftTapAction: (() -> ())? {
        didSet {
            setupNavigationGestures()
        }
    }
    
    /// Action that is executed when the right side of the view is tapped
    public var rightTapAction: (() -> ())? {
        didSet {
            setupNavigationGestures()
        }
    }
    
    /// Action that is executed when the view detects a long press
    public var longPressAction: (() -> ())? {
        didSet {
            setupNavigationGestures()
        }
    }
    
    /// Action that is executed when the view is released after a long press
    public var releaseLongPressAction: (() -> ())? {
        didSet {
            setupNavigationGestures()
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
        setupNavigationGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupComponents()
        setupNavigationGestures()
    }
    
    //MARK: - Methods
    /// Manually move to a specific index and story
    public func moveTo(index: Int) {
        viewModel.setIndex(viewModel.isValid(index: index) ? index : 0)
        setupBars()
        if viewModel.currentIndex() > 0 {
            fillBars(upTo: viewModel.currentIndex()-1)
        }
        resetAnimations()
    }
    
    /// Setup stories to be displayed  by the view and the index of the story to be displayed
    public func stories(_ stories: [Story]?, moveTo index: Int = 0) {
        viewModel.setStories(stories)
        moveTo(index: index)
    }
    /// Set the amount of time (in seconds) until the feed moves to the next story automatically. The default time is 5 seconds
    public func setTimeLimit(_ timeLimit: TimeInterval) {
        viewModel.timeLimit = timeLimit
    }
    
    private func resetAnimations() {
        stopAnimations()
        self.headlineLabel.alpha = 0.0
        self.imageViewAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .linear, animations: {
            UIView.transition(with: self.imageView,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.imageView.image = self.viewModel.image() },
                              completion: nil)
        })
        imageViewAnimator.addCompletion { _ in
            self.headlineLabel.text = self.viewModel.headline()
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
}

//MARK: - Gestures
extension StoryFeedView {
    //Setup methods
    private func setupNavigationGestures() {
        let tapGestureRecongnizer = UITapGestureRecognizer(target: self, action: #selector(executeTap))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        addGestureRecognizer(tapGestureRecongnizer)
        addGestureRecognizer(longPressRecognizer)
    }

    @objc private func executeTap(tap: UITapGestureRecognizer) {
        let tapLocation = tap.location(in: self)
        let leftArea = CGRect(x: 0, y: 0, width: bounds.width/4, height: bounds.height)
        let rightArea = CGRect(x: bounds.width, y: 0, width: -bounds.width/4, height: bounds.height)
        if leftArea.contains(tapLocation) {
            leftAction()
        } else if rightArea.contains(tapLocation) {
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
        if viewModel.isOverlappingIndex(isIncreasing: false) {
            fillBars(upTo: viewModel.previousIndex()-1)
        } else {
            self.progressViews[self.viewModel.currentIndex()].setProgress(0.0, animated: false)
            self.progressViews[self.viewModel.previousIndex()].setProgress(0.0, animated: false)
        }
        self.viewModel.decreaseIndex()
        resetAnimations()
        self.leftTapAction?()
    }
    
    @objc private func rightAction() {
        self.nextProgress()
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
        self.nextProgress()
        self.timerDidEnd?()
    }
}

//MARK: - Progress Bar
extension StoryFeedView {
    private func setupBars() {
        self.progressStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        guard let amount = viewModel.amount else { return }
        for _ in 0 ..< amount {
            progressStackView.addArrangedSubview(newProgressBar())
        }
    }
    
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
        progressView.backgroundColor = viewModel.progressBackgroundColor()
        progressView.progress = 0.0
        progressView.layer.cornerRadius = 2.0
        progressView.heightAnchor.constraint(equalToConstant: 2.0).isActive = true
        progressView.tintColor = self.progressTintColor
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }
    
    private func startProgress(for progressView: UIProgressView) {
        progressBarAnimator = viewModel.animator(animations: {
            progressView.setProgress(1.0, animated: true)
        }, completion: { _ in
            progressView.setProgress(0.0, animated: false)
            self.timerAction()
        })
        progressBarAnimator.startAnimation()
    }
    
    private func nextProgress() {
        if viewModel.isOverlappingIndex(isIncreasing: true) {
            resetProgress()
        } else {
            self.fillBars(upTo: viewModel.currentIndex())
        }
        self.viewModel.increaseIndex()
        resetAnimations()
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
            
            self.gradientView.heightAnchor.constraint(equalToConstant: self.bounds.height/2.2),
            self.headlineLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            self.headlineLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            self.headlineLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            
            self.progressStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 6),
            self.progressStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            self.progressStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4),
            self.progressStackView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setupGradient() {
        self.gradientView.alpha = 0.0
        gradient.colors = viewModel.gradientColors()
        gradient.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height/2.2)
        gradientView.layer.insertSublayer(gradient, at: 0)
        UIView.animate(withDuration: 0.5) {
            self.gradientView.alpha = 1.0
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupGradient()
    }
}
