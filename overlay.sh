#!/bin/sh

# Simple ver
#
# magick \
#   \( "backgrounds/00371-884780754.png" -fx "0.8*u" \) \
#   \( "overlays/1_3girls, from below, arms behind back, pantyshot.png" -resize 250% \) \
#   -compose Screen -composite \
#   Screen.png

# Normal ver
openposePath=$(ls openposes/*.png | head -n 1)

echo "----------------------------------------------"

openposeBase="${openposePath#*openposes/}"
openposeName="${openposeBase%.*}"
openposeExt="${openposeBase#*.}"

echo "openposePath                : ${openposePath}"
echo "openposeBase                : ${openposeBase}"
echo "openposeName                : ${openposeName}"
echo "openposeExt                 : ${openposeExt}"
echo ""

tempDir="temp"
openposeGreyScalePath="${tempDir}/${openposeName}_greyscale.png"
openposeMaskPath="${tempDir}/${openposeName}_mask.png"
openposeTransparentThinPath="${tempDir}/${openposeName}_transparent_thin.png"
openposeTransparentPath="${tempDir}/${openposeName}_transparent.png"

echo "tempDir                     : ${tempDir}"
echo "openposeGreyScalePath       : ${openposeGreyScalePath}"
echo "openposeMaskPath            : ${openposeMaskPath}"
echo "openposeTransparentThinPath : ${openposeTransparentThinPath}"
echo "openposeTransparentPath     : ${openposeTransparentPath}"
echo ""

mkdir -p "${tempDir}"

# Convert to bright greyscale image.
magick "${openposePath}" -modulate 100,0 -fx "u*3" "${openposeGreyScalePath}"
# Erode to avoid semi-black pixels in the border area.
magick "${openposeGreyScalePath}" -morphology Erode Octagon:1 "${openposeMaskPath}"
# Create transparent OpenPose image that is thin due to eroding.
magick "${openposePath}" \( "${openposeMaskPath}" -alpha off \) \
  -compose CopyOpacity -composite "${openposeTransparentThinPath}"
# Dilate to change thickness.
magick "${openposeTransparentThinPath}" -morphology Dilate Octagon:1 "${openposeTransparentPath}"

mkdir -p outputs

for backgroundPath in backgrounds/*.png; do
  backgroundBase="${backgroundPath#*backgrounds/}"
  backgroundName="${backgroundBase%.*}"
  overlayPath="outputs/${backgroundName}_overlay.png"

  echo "backgroundBase              : ${backgroundBase}"
  echo "backgroundName              : ${backgroundName}"
  echo "overlayPath                 : ${overlayPath}"

  # Resize the transparent OpenPose image to fit the background image and overlay these.
  magick \( "${backgroundPath}" -fx "0.9*u" \) \
    \( "${openposeTransparentPath}" \) \
    -resize %[fx:u.w]x%[fx:u.h] -composite \
    "${overlayPath}"
done
