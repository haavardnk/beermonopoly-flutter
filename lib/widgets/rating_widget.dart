import 'package:flutter/material.dart';

Widget createRatingBar(
    {double rating = 5, double size = 24, required Color color}) {
  if (rating < 0) {
    rating = 0;
  } else if (rating > 5) {
    rating = 5;
  }

  bool _absolute = false;
  int _fullStar = 0;
  int _emptyStar = 0;

  if (rating == 0 ||
      rating == 1 ||
      rating == 2 ||
      rating == 3 ||
      rating == 4 ||
      rating == 5) {
    _absolute = true;
  } else {
    double _dec = (rating - int.parse(rating.toString().substring(0, 1)));
    if (_dec > 0 && _dec < 1) {
      if (_dec >= 0.25 && _dec <= 0.75) {
        _absolute = false;
      } else {
        _absolute = true;
        if (_dec < 0.25) {
          _emptyStar = 1;
        } else if (_dec > 0.75) {
          _fullStar = 1;
        }
      }
    }
  }
  return Row(
    children: [
      for (int i = 1; i <= rating + _fullStar; i++)
        Icon(Icons.star, color: color, size: size),
      !_absolute
          ? Icon(Icons.star_half, color: color, size: size)
          : const SizedBox.shrink(),
      for (int i = 1; i <= (5 - rating + _emptyStar); i++)
        Icon(Icons.star_border, color: color, size: size),
    ],
  );
}
