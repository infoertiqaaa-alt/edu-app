import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LessonVideoControls extends StatefulWidget {
  const LessonVideoControls({super.key, required this.controller});

  final YoutubePlayerController controller;

  @override
  State<LessonVideoControls> createState() => _LessonVideoControlsState();
}

class _LessonVideoControlsState extends State<LessonVideoControls> {
  StreamSubscription<YoutubePlayerValue>? _valueSub;
  StreamSubscription<YoutubeVideoState>? _stateSub;
  Timer? _hideTimer;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _loadedFraction = 0;
  PlayerState _playerState = PlayerState.unknown;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _duration = widget.controller.metadata.duration;
    _playerState = widget.controller.value.playerState;
    _valueSub = widget.controller.listen(_onValueChanged);
    _stateSub = widget.controller.videoStateStream.listen(_onStateChanged);
    _handleStateChange(_playerState);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _valueSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  void _onValueChanged(YoutubePlayerValue value) {
    if (!mounted) return;
    setState(() {
      _duration = value.metaData.duration;
      _playerState = value.playerState;
    });
    _handleStateChange(value.playerState);
    if (value.playerState == PlayerState.ended) {
      widget.controller.seekTo(seconds: 0, allowSeekAhead: true);
      widget.controller.playVideo();
    }
  }

  void _onStateChanged(YoutubeVideoState state) {
    if (!mounted) return;
    setState(() {
      _position = state.position;
      _loadedFraction = state.loadedFraction;
    });
  }

  void _handleStateChange(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        _scheduleAutoHide();
      case PlayerState.paused:
      case PlayerState.buffering:
      case PlayerState.ended:
      case PlayerState.cued:
        _hideTimer?.cancel();
        _showControls();
      default:
        _hideTimer?.cancel();
    }
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_playerState == PlayerState.playing) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _showControls() {
    _hideTimer?.cancel();
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    if (_playerState == PlayerState.playing) _scheduleAutoHide();
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  void _togglePlay() {
    if (_playerState == PlayerState.playing) {
      widget.controller.pauseVideo();
    } else {
      widget.controller.playVideo();
    }
    _showControls();
  }

  void _seekBy(Duration delta) {
    final totalSeconds = _duration.inSeconds.toDouble();
    if (totalSeconds <= 0) return;
    final target = (_position.inSeconds + delta.inSeconds)
        .clamp(0.0, totalSeconds)
        .toDouble();
    widget.controller.seekTo(seconds: target, allowSeekAhead: true);
    _showControls();
  }

  void _seekToFraction(double fraction) {
    final totalSeconds = _duration.inSeconds.toDouble();
    if (totalSeconds <= 0) return;
    widget.controller.seekTo(
      seconds: (fraction.clamp(0.0, 1.0) * totalSeconds).roundToDouble(),
      allowSeekAhead: true,
    );
    _showControls();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: AnimatedOpacity(
          opacity: _controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !_controlsVisible,
            child: _buildControls(),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        const _TopScrim(),
        const _BottomScrim(),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SkipButton(
                label: '-10m',
                icon: Icons.fast_rewind_rounded,
                onTap: () => _seekBy(const Duration(minutes: -10)),
              ),
              SizedBox(width: 14.w),
              _PlayPauseButton(
                state: _playerState,
                onTap: _togglePlay,
              ),
              SizedBox(width: 14.w),
              _SkipButton(
                label: '+10m',
                icon: Icons.fast_forward_rounded,
                onTap: () => _seekBy(const Duration(minutes: 10)),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12.w,
          top: 8.h,
          child: _FullscreenButton(controller: widget.controller),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: 10.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SeekBar(
                fraction: progress,
                bufferedFraction: _loadedFraction.clamp(0.0, 1.0),
                onSeek: _seekToFraction,
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Text(
                    _formatDuration(_position),
                    style: _timestampStyle(),
                  ),
                  const Spacer(),
                  Text(
                    _formatDuration(_duration),
                    style: _timestampStyle(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

TextStyle _timestampStyle() => GoogleFonts.cairo(
  fontSize: 10.sp,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

String _formatDuration(Duration duration) {
  final h = duration.inHours;
  final m = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final s = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x73000000), Colors.transparent],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0x99000000)],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SkipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: const Color(0x66000000),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.w, color: Colors.white),
            SizedBox(height: 1.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final PlayerState state;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isBuffering = state == PlayerState.buffering;
    final isPlaying = state == PlayerState.playing;
    final isEnded = state == PlayerState.ended;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 58.w,
        height: 58.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0x99000000),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: isBuffering
            ? Padding(
                padding: EdgeInsets.all(16.w),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5.w,
                  color: Colors.white,
                ),
              )
            : Icon(
                isPlaying
                    ? Icons.pause_rounded
                    : isEnded
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 34.w,
              ),
      ),
    );
  }
}

class _FullscreenButton extends StatelessWidget {
  final YoutubePlayerController controller;

  const _FullscreenButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return YoutubeValueBuilder(
      controller: controller,
      buildWhen: (o, n) => o.fullScreenOption != n.fullScreenOption,
      builder: (context, value) {
        final isFullscreen = value.fullScreenOption.enabled;
        return GestureDetector(
          onTap: () => controller.toggleFullScreen(),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x66000000),
              border: Border.all(color: const Color(0x33FFFFFF)),
            ),
            child: Icon(
              isFullscreen
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              size: 20.w,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

class _SeekBar extends StatefulWidget {
  final double fraction;
  final double bufferedFraction;
  final ValueChanged<double> onSeek;

  const _SeekBar({
    required this.fraction,
    required this.bufferedFraction,
    required this.onSeek,
  });

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  static const double _thumbSize = 12;

  double? _dragFraction;

  double _updateFromDx(double dx, double width) {
    if (width <= 0) return 0;
    return (dx / width).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final displayFraction = _dragFraction ?? widget.fraction;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            setState(
              () => _dragFraction = _updateFromDx(details.localPosition.dx, width),
            );
          },
          onTapUp: (_) => _commit(),
          onTapCancel: () => setState(() => _dragFraction = null),
          onHorizontalDragStart: (details) {
            setState(
              () => _dragFraction = _updateFromDx(details.localPosition.dx, width),
            );
          },
          onHorizontalDragUpdate: (details) {
            setState(
              () => _dragFraction = _updateFromDx(details.localPosition.dx, width),
            );
          },
          onHorizontalDragEnd: (_) => _commit(),
          onHorizontalDragCancel: () => setState(() => _dragFraction = null),
          child: SizedBox(
            height: 30.h,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: const Color(0x40FFFFFF),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: widget.bufferedFraction,
                  child: Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: const Color(0x66FFFFFF),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: displayFraction,
                  child: Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                if (displayFraction > 0 && width > 0)
                  Positioned(
                    left: (width - _thumbSize) * displayFraction,
                    child: const Center(
                      child: SizedBox(
                        width: _thumbSize,
                        height: _thumbSize,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(color: Color(0x59000000), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _commit() {
    final target = _dragFraction ?? widget.fraction;
    setState(() => _dragFraction = null);
    widget.onSeek(target);
  }
}