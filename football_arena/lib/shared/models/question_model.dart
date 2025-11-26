import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'question_model.g.dart';

enum QuestionType {
  multipleChoice,
  trueFalse,
  imageBased,
  mediaBased,
}

enum QuestionDifficulty {
  easy,
  medium,
  hard,
}

@JsonSerializable()
class QuestionModel extends Equatable {
  final String id;
  final String text;
  final String textAr; // Arabic translation
  final QuestionType type;
  final List<String> options;
  final List<String> optionsAr; // Arabic options
  final String correctAnswer;
  final QuestionDifficulty difficulty;
  final List<String> categories;
  final String? imageUrl;
  final String? videoUrl;
  final String? explanation;
  final String? explanationAr;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.textAr,
    required this.type,
    required this.options,
    required this.optionsAr,
    required this.correctAnswer,
    required this.difficulty,
    required this.categories,
    this.imageUrl,
    this.videoUrl,
    this.explanation,
    this.explanationAr,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  QuestionModel copyWith({
    String? id,
    String? text,
    String? textAr,
    QuestionType? type,
    List<String>? options,
    List<String>? optionsAr,
    String? correctAnswer,
    QuestionDifficulty? difficulty,
    List<String>? categories,
    String? imageUrl,
    String? videoUrl,
    String? explanation,
    String? explanationAr,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      textAr: textAr ?? this.textAr,
      type: type ?? this.type,
      options: options ?? this.options,
      optionsAr: optionsAr ?? this.optionsAr,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      difficulty: difficulty ?? this.difficulty,
      categories: categories ?? this.categories,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      explanation: explanation ?? this.explanation,
      explanationAr: explanationAr ?? this.explanationAr,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        textAr,
        type,
        options,
        optionsAr,
        correctAnswer,
        difficulty,
        categories,
        imageUrl,
        videoUrl,
        explanation,
        explanationAr,
        isActive,
        createdAt,
        updatedAt,
      ];
}

