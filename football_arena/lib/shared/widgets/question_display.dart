import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';

/// Widget to display questions with support for all question types
class QuestionDisplay extends StatefulWidget {
  final Map<String, dynamic> question;
  final String? selectedAnswer;
  final bool isAnswered;
  final Function(String) onAnswerSelected;

  const QuestionDisplay({
    super.key,
    required this.question,
    this.selectedAnswer,
    this.isAnswered = false,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionDisplay> createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends State<QuestionDisplay> {
  VideoPlayerController? _videoController;
  String? _questionType;

  @override
  void initState() {
    super.initState();
    // Handle both enum string and camelCase formats
    final type = widget.question['type'] ?? 'multipleChoice';
    _questionType = type.toString().toLowerCase()
        .replaceAll('_', '')
        .replaceAll('multiplechoice', 'multipleChoice')
        .replaceAll('truefalse', 'trueFalse')
        .replaceAll('imagebased', 'imageBased')
        .replaceAll('mediabased', 'mediaBased');
    _initializeMedia();
  }

  void _initializeMedia() {
    if (_questionType == 'mediaBased' && widget.question['videoUrl'] != null) {
      try {
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.question['videoUrl']),
        )..initialize().then((_) {
            if (mounted) {
              setState(() {});
            }
          }).catchError((error) {
            print('Video initialization error: $error');
          });
      } catch (e) {
        print('Error creating video controller: $e');
      }
    }
  }

  @override
  void dispose() {
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Question Text
        _buildQuestionText(),
        
        // Media Content (Image or Video)
        if (_questionType == 'imageBased' && widget.question['imageUrl'] != null)
          _buildImageQuestion(),
        if (_questionType == 'mediaBased' && widget.question['videoUrl'] != null)
          _buildVideoQuestion(),
        
        const SizedBox(height: 24),
        
        // Answer Options
        _buildAnswerOptions(),
      ],
    );
  }

  Widget _buildQuestionText() {
    // Support both 'text' and 'question' keys for flexibility
    final questionText = widget.question['text'] ?? widget.question['question'] ?? '';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        questionText,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildImageQuestion() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          widget.question['imageUrl'],
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              color: AppColors.cardBackground,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: AppColors.cardBackground,
              child: const Center(
                child: Icon(Icons.error, color: Colors.red, size: 48),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoQuestion() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        height: 200,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              if (!_videoController!.value.isPlaying)
                IconButton(
                  icon: const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _videoController!.play();
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerOptions() {
    // True/False questions have only 2 options
    if (_questionType == 'trueFalse') {
      return Column(
        children: [
          _buildOptionButton('True', 'True'),
          const SizedBox(height: 12),
          _buildOptionButton('False', 'False'),
        ],
      );
    }

    // Multiple choice and image-based questions
    final options = List<String>.from(widget.question['options'] ?? []);
    return Column(
      children: options.map((option) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildOptionButton(option, option),
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton(String option, String value) {
    final isSelected = widget.selectedAnswer == value;
    final isCorrect = value == widget.question['correctAnswer'];
    
    Color? backgroundColor;
    Color? borderColor;
    IconData? icon;

    if (widget.isAnswered) {
      if (isSelected) {
        backgroundColor = isCorrect
            ? AppColors.success.withOpacity(0.2)
            : AppColors.error.withOpacity(0.2);
        borderColor = isCorrect ? AppColors.success : AppColors.error;
        icon = isCorrect ? Icons.check_circle : Icons.cancel;
      } else if (isCorrect) {
        backgroundColor = AppColors.success.withOpacity(0.2);
        borderColor = AppColors.success;
        icon = Icons.check_circle;
      }
    }

    return InkWell(
      onTap: widget.isAnswered ? null : () => widget.onAnswerSelected(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected && !widget.isAnswered
              ? AppColors.primaryGradient
              : null,
          color: backgroundColor ??
              (isSelected && !widget.isAnswered
                  ? null
                  : AppColors.cardBackground),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ??
                (isSelected ? AppColors.primary : AppColors.border),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Option letter/number (for multiple choice)
            if (_questionType != 'trueFalse')
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + (widget.question['options'] as List).indexOf(option)),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (_questionType != 'trueFalse') const SizedBox(width: 16),
            
            // Option text
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected && !widget.isAnswered
                      ? Colors.white
                      : Colors.white70,
                ),
              ),
            ),
            
            // Result icon
            if (widget.isAnswered && icon != null)
              Icon(
                icon,
                color: isCorrect ? AppColors.success : AppColors.error,
              ),
          ],
        ),
      ),
    );
  }
}

