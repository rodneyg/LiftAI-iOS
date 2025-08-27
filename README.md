# LiftAI 🏋️‍♂️

**AI-Powered Personalized Fitness Planning for iOS**

LiftAI is an intelligent iOS fitness app that creates personalized workout plans using artificial intelligence. Simply set your fitness goals, snap photos of your available equipment, and let AI generate customized workouts tailored specifically for you.

<p align="center">
  <img src="https://github.com/user-attachments/assets/a3af76f0-4940-4adc-99d6-f95134df32f1" width="200" alt="Goal Selection"/>
  <img src="https://github.com/user-attachments/assets/386f5b0f-84ee-481d-b8c3-b92bcfada516" width="200" alt="Training Context"/>
  <img src="https://github.com/user-attachments/assets/c29fa60b-ff51-464a-8b49-13b431142ab7" width="200" alt="Equipment Capture"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/9207390f-c369-40b5-8d42-16621cc400b4" width="200" alt="AI Detection"/>
  <img src="https://github.com/user-attachments/assets/68b612dc-d494-4cb7-973b-042c4770557f" width="200" alt="Workout Plan"/>
  <img src="https://github.com/user-attachments/assets/7315010d-94ed-47f9-a17a-3fd957f6ff6a" width="200" alt="Dashboard"/>
</p>


![iOS](https://img.shields.io/badge/iOS-15.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-✓-green)
![OpenAI](https://img.shields.io/badge/OpenAI-API-purple)

## ✨ Key Features

### 🎯 **Smart Goal Setting**
- **Strength Building** - Focus on compound movements and progressive overload
- **Muscle Growth** - Hypertrophy-optimized rep ranges and volume
- **Fat Loss** - High-intensity circuits and metabolic conditioning
- **Endurance** - Cardiovascular and muscular endurance training
- **Mobility** - Flexibility and movement quality improvement

### 📸 **AI-Powered Equipment Detection**
- **Computer Vision Integration** - Automatically identify gym equipment from photos
- **Smart Recognition** - Detects 20+ types of fitness equipment including barbells, dumbbells, machines, and more
- **Context Aware** - Adapts workout plans based on available equipment (gym vs. home)

### 🤖 **Intelligent Workout Generation**
- **OpenAI Integration** - Leverages GPT models for expert-level workout programming
- **Personalized Plans** - 3 distinct workouts per goal with 4-6 exercises each
- **Technical Precision** - Includes sets, reps, tempo, and primary muscle targets
- **Equipment Optimization** - Substitutes exercises based on available equipment

### 📊 **Seamless Experience**
- **Native iOS Design** - Built with SwiftUI for smooth, native performance
- **Session Management** - Save and resume workout plans across app sessions
- **Progress Tracking** - View workout history and plan details
- **Offline Capable** - Continue using saved plans without internet connection

## 🎬 Screenshots

The app screenshots above showcase the complete user flow from goal selection through workout plan generation, demonstrating the clean, modern iOS interface and intuitive user experience.

## 🏗️ Technical Architecture

### **Core Technologies**
- **SwiftUI** - Modern declarative UI framework for iOS
- **OpenAI API** - GPT models for both workout generation and equipment detection
- **Computer Vision** - Image analysis for automatic equipment recognition
- **Core Data** - Local persistence for workout plans and user preferences

### **Architecture Highlights**
```
├── Features/           # Feature-based architecture
│   ├── Goal/          # Goal selection flow
│   ├── Context/       # Training environment setup
│   ├── Capture/       # Photo capture for equipment detection
│   ├── Detect/        # AI equipment detection
│   ├── Plan/          # Workout plan generation and display
│   └── Dashboard/     # Main app dashboard
├── Models/            # Core data models
├── Services/          # Business logic and API integration
└── Global/           # Shared utilities and components
```

### **Key Design Patterns**
- **MVVM Architecture** - Clean separation of concerns with ViewModels
- **Flow-Based Navigation** - Structured user journey management
- **Protocol-Oriented Design** - Testable and flexible service interfaces
- **Reactive Programming** - Combine framework for state management

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+**
- **iOS 15.0+**
- **OpenAI API Key** (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rodneyg/LiftAI-iOS.git
   cd LiftAI-iOS
   ```

2. **Configure API Keys**
   - Add your OpenAI API key to `LiftAI/Support/Secrets.plist`
   ```xml
   <key>OpenAI_API_Key</key>
   <string>your-openai-api-key-here</string>
   ```

3. **Open in Xcode**
   ```bash
   open LiftAI.xcodeproj
   ```

4. **Build and Run**
   - Select your target device or simulator
   - Press `⌘R` to build and run

### Development Setup

```bash
# Install development dependencies (if any)
# Run tests
⌘U in Xcode

# Build for release
⌘B in Xcode
```

## 🧪 Testing

LiftAI includes a comprehensive testing suite ensuring reliability and quality:

### **Test Coverage**
- **Unit Tests** - Core business logic and data models
- **Plan Engine Tests** - Workout generation algorithm validation
- **API Integration Tests** - OpenAI service integration testing
- **Detection Parsing Tests** - Equipment detection accuracy tests
- **UI Tests** - End-to-end user flow validation

### **Running Tests**
```bash
# Run all tests in Xcode
⌘U

# Run specific test suite
⌘U (select specific test target)
```

### **Key Test Categories**
- **PlanEngineTests** - Validates workout generation logic for different goals and equipment
- **DetectionParsingTests** - Ensures accurate equipment detection from AI responses  
- **PlanAIDecodingTests** - Verifies proper parsing of OpenAI workout responses

## 🎨 UI/UX Highlights

- **Modern Design Language** - Clean, minimalist interface with thoughtful animations
- **Accessibility First** - VoiceOver support and accessibility labels throughout
- **Dark Mode Support** - Seamless light/dark mode transitions
- **Haptic Feedback** - Tactile responses for enhanced user experience
- **Performance Optimized** - Smooth 60fps animations and transitions

## 🔧 Configuration

### **API Configuration**
The app requires an OpenAI API key for AI features. Add your key to `Secrets.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>OpenAI_API_Key</key>
    <string>your-api-key-here</string>
</dict>
</plist>
```

### **Build Configurations**
- **Debug** - Development builds with logging and mock services
- **Release** - Production builds with optimizations and real API integration

## 🤝 Contributing

We welcome contributions! Please see our contributing guidelines:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### **Development Guidelines**
- Follow Swift API Design Guidelines
- Maintain test coverage for new features
- Use SwiftLint for code formatting consistency
- Document public APIs with DocC comments

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenAI** - For providing the powerful AI models that make intelligent workout generation possible
- **Apple** - For the excellent SwiftUI framework and development tools
- **Fitness Community** - For inspiration and domain expertise in workout programming

---

**Built with ❤️ by [Rodney Gainous Jr](https://github.com/rodneyg)**

*LiftAI - Where AI meets fitness. Transform your training with intelligent, personalized workout plans.*
