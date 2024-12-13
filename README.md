# 💪 AI Personal Trainer

AI Personal Trainer is a Flutter-based application designed to generate personalized workout plans using OpenAI's GPT model. The app allows users to specify their training preferences, such as training days, goals, modalities, and duration, and generates a tailored workout plan based on these inputs.

## ✨ Features

- **🛠️ Customizable Workouts**: Define your training days, fitness goals, preferred training modalities, and workout duration.
- **🧠 AI-Powered Planning**: Utilizes OpenAI's GPT-3.5-Turbo to create personalized workout plans.
- **🎨 Interactive UI**: Step-by-step forms to input your workout preferences.
- **⚙️ State Management**: Powered by the `Provider` package for efficient app state management.

## 🛠️ Technologies Used

- **Flutter**: For building the user interface.
- **dart_openai**: To interact with the OpenAI API.
- **dotenv**: For managing environment variables securely.
- **Provider**: For state management.

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK**: Ensure you have Flutter installed. [Installation Guide](https://flutter.dev/docs/get-started/install)
2. **Dart**: Included with Flutter.
3. **OpenAI API Key**: Sign up at [OpenAI](https://platform.openai.com/signup/) to get your API key.

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repository-url/ai-personal-trainer.git
   cd ai-personal-trainer
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up environment variables:
   - Create a `.env` file in the root directory.
   - Add your API key and base URL:
     ```env
     API_KEY=your_openai_api_key
     API_URL=https://api.openai.com/v1
     SYS_PROMPT=Create a workout plan based on user preferences.
     ```

4. Run the app:
   ```bash
   flutter run
   ```

## 🏋️ How to Use

1. Open the app.
2. Click on the **➕** button to start creating a new workout plan.
3. Follow the step-by-step forms:
   - 📅 Select the days you want to train.
   - 🎯 Choose your fitness goals.
   - 🏃‍♂️ Pick your preferred training modalities (e.g., calisthenics, weightlifting).
   - ⏱️ Specify the maximum duration of your workout.
4. Click **Generate Workout** to receive a personalized workout plan.

## 📂 Project Structure

- **`lib/`**: Contains the main application code.
  - **`main.dart`**: Entry point of the app.
  - **State Management**: `MyAppState` class manages the workout request and generated plans.
  - **UI Components**: Includes forms for selecting days, goals, modalities, and duration.
- **Dependencies**: `dart_openai`, `dotenv`, `provider`, `flutter/material.dart`.

## 🤝 Contributing

Contributions are welcome! Please fork the repository and create a pull request with your changes.

## 📜 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## 🙌 Acknowledgments

- [OpenAI](https://openai.com/) for providing the GPT model.
- The Flutter community for extensive documentation and support.

---

Start your fitness journey today with **AI Personal Trainer**! 💪🤩

