import SwiftUI

struct LessonDetailView: View {
    let lesson: Lesson
    @StateObject private var viewModel: LessonDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var themeManager: ThemeManager
    
    init(lesson: Lesson) {
        self.lesson = lesson
        _viewModel = StateObject(wrappedValue: LessonDetailViewModel(lesson: lesson))
    }
    
    var body: some View {
        ZStack {
            themeManager.backgroundColor
                .ignoresSafeArea()
            
            VStack {
                // Header with hearts and progress
                HStack {
                    // Hearts
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("\(viewModel.remainingHearts)")
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.textColor)
                    }
                    
                    Spacer()
                    
                    // Progress
                    Text("\(viewModel.currentExerciseIndex + 1)/\(viewModel.totalExercises)")
                        .fontWeight(.medium)
                        .foregroundColor(themeManager.textColor)
                    
                    Spacer()
                    
                    // Close button
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(themeManager.textColor)
                    }
                }
                .padding()
                
                // Progress bar
                ProgressView(value: Double(viewModel.currentExerciseIndex + 1), total: Double(viewModel.totalExercises))
                    .tint(themeManager.accentColor)
                    .padding(.horizontal)
                
                // Exercise content
                if let currentExercise = viewModel.currentExercise {
                    ExerciseView(exercise: currentExercise, viewModel: viewModel)
                        .padding()
                }
                
                Spacer()
                
                // Bottom button
                Button(action: viewModel.checkAnswer) {
                    Text(viewModel.isAnswerSubmitted ? "Devam Et" : "Kontrol Et")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .disabled(!viewModel.canSubmitAnswer)
                .padding()
            }
        }
        .navigationBarHidden(true)
        .alert("Ders Tamamlandı!", isPresented: $viewModel.showCompletionAlert) {
            Button("Tamam") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Tebrikler! \(viewModel.earnedXP) XP ve \(viewModel.earnedGems) Gem kazandınız!")
        }
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: LessonDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Question
            Text(exercise.question)
                .font(.title3)
                .multilineTextAlignment(.center)
            
            // Exercise content based on type
            switch exercise.type {
            case .wordMatching, .quiz, .multipleChoice:
                MultipleChoiceView(exercise: exercise, viewModel: viewModel)
                
            case .fillInBlanks:
                FillInBlanksView(exercise: exercise, viewModel: viewModel)
                
            case .listening:
                ListeningExerciseView(exercise: exercise, viewModel: viewModel)
                
            case .speechRecognition, .speaking:
                SpeechRecognitionView(exercise: exercise, viewModel: viewModel)
            }
        }
    }
}

struct MultipleChoiceView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: LessonDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(exercise.options ?? [], id: \.self) { option in
                Button(action: { viewModel.selectOption(option) }) {
                    HStack {
                        Text(option)
                            .foregroundColor(getOptionColor(option))
                        Spacer()
                        if viewModel.isAnswerSubmitted && option == exercise.correctAnswer {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(getOptionBackground(option))
                    .cornerRadius(12)
                }
                .disabled(viewModel.isAnswerSubmitted)
            }
        }
    }
    
    private func getOptionColor(_ option: String) -> Color {
        if !viewModel.isAnswerSubmitted {
            return viewModel.selectedOption == option ? .white : themeManager.textColor
        } else {
            if option == exercise.correctAnswer {
                return .white
            } else if option == viewModel.selectedOption {
                return .white
            }
            return themeManager.textColor
        }
    }
    
    private func getOptionBackground(_ option: String) -> Color {
        if !viewModel.isAnswerSubmitted {
            return viewModel.selectedOption == option ? Color(red: 29/255, green: 161/255, blue: 242/255) : themeManager.inputBackgroundColor
        } else {
            if option == exercise.correctAnswer {
                return .green
            } else if option == viewModel.selectedOption && option != exercise.correctAnswer {
                return .red
            }
            return themeManager.inputBackgroundColor
        }
    }
}

struct FillInBlanksView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: LessonDetailViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            TextField("Cevabınızı yazın", text: $viewModel.userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(themeManager.textColor)
                .disabled(viewModel.isAnswerSubmitted)
            
            if let hint = exercise.hint {
                Text("İpucu: \(hint)")
                    .font(.caption)
                    .foregroundColor(themeManager.secondaryTextColor)
            }
        }
    }
}

struct ListeningExerciseView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: LessonDetailViewModel
    
    var body: some View {
        VStack {
            Button(action: { /* Play audio */ }) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            
            TextField("Duyduğunuz cümleyi yazın", text: $viewModel.userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(viewModel.isAnswerSubmitted)
        }
    }
}

struct SpeechRecognitionView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: LessonDetailViewModel
    
    var body: some View {
        VStack {
            Button(action: { /* Start recording */ }) {
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(viewModel.isRecording ? .red : .blue)
            }
            
            if !viewModel.userInput.isEmpty {
                Text(viewModel.userInput)
                    .padding()
            }
        }
    }
}

#Preview {
    LessonDetailView(lesson: Lesson(
        id: 1,
        title: "Selamlaşma",
        type: .vocabulary,
        isUnlocked: true,
        isCompleted: false
    ))
} 