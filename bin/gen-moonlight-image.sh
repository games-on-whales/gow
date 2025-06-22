#! /usr/bin/env python3
###########################################################################
# Adapted from https://github.com/AshDevFr/Sunshine-Cover-Generator/
# Uses PIL for image generation and requests to pull the icons
# pip install argparse pillow requests
#####
import argparse
from PIL import Image, ImageDraw, ImageFont
import requests
from io import BytesIO
import sys


def generate_gradient(width, height, start_color, end_color):
    base = Image.new('RGB', (width, height), start_color)
    top = Image.new('RGB', (width, height), end_color)
    mask = Image.new('L', (width, height))
    mask_draw = ImageDraw.Draw(mask)

    for y in range(height):
        # Draw horizontal lines with varying alpha
        alpha = int(255 * (y / height))
        mask_draw.line((0, y, width, y), fill=alpha)

    base.paste(top, (0, 0), mask)
    return base


def load_material_icon_font(font_size):
    font_url = 'https://github.com/google/material-design-icons/blob/master/font/MaterialIcons-Regular.ttf?raw=true'
    response = requests.get(font_url)
    font_data = BytesIO(response.content)
    return ImageFont.truetype(font_data, font_size)


def generate_png_image(start_color, end_color, icon_name, text_lines, font_path, font_size, output_path):
    # Constants
    canvas_width = 600
    canvas_height = 800
    icon_size = 200  # You can adjust this size as needed

    # Create a gradient background
    background = generate_gradient(canvas_width, canvas_height, start_color, end_color)

    # Create a blank canvas
    image = Image.new('RGB', (canvas_width, canvas_height), 'white')
    draw = ImageDraw.Draw(image)
    image.paste(background, (0, 0))

    # Load and place the Material Icon
    icon_font = load_material_icon_font(icon_size)
    icon_text = chr(int(icon_name, 16))  # Convert icon name to Unicode character
    bbox = draw.textbbox((0, 0), icon_text, font=icon_font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    icon_position = ((canvas_width - text_width) // 2, (canvas_height - text_height - 50) // 2)
    draw.text(icon_position, icon_text, font=icon_font, fill='white')

    # Load font
    font = ImageFont.truetype(font_path, font_size)

    # Write text lines
    y_text = icon_position[1] + text_height + 50
    for line in text_lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        text_position = ((canvas_width - text_width) // 2, y_text)
        draw.text(text_position, line, font=font, fill='white')
        y_text += text_height * 1.2

    # Save the result
    image.save(output_path, 'PNG')
    print(f"Image saved to {output_path}")


def gen_all_icons():
    categories = [{"start": "#7A0035", "end": "#2E0014", "icon": "e30c"},  # Desktop
                  {"start": "#326771", "end": "#654236", "icon": "e338"},  # Emulators
                  {"start": "#1A936F", "end": "#0E3B43", "icon": "f02e"}]  # Launchers

    apps = [
        # Desktop apps
        {"name": ["Firefox"], "palette": 0, "output": "apps/firefox/assets/icon.png"},
        {"name": ["Kodi"], "palette": 0, "output": "apps/kodi/assets/icon.png"},
        {"name": ["XFCE", "(desktop)"], "palette": 0, "output": "apps/xfce/assets/icon.png"},
        # Emulators / Games
        {"name": ["Emulation Station"], "palette": 1, "output": "apps/es-de/assets/icon.png"},
        {"name": ["Retroarch"], "palette": 1, "output": "apps/retroarch/assets/icon.png"},
        {"name": ["Pegasus"], "palette": 1, "output": "apps/pegasus/assets/icon.png"},
        # Launchers
        {"name": ["Steam"], "palette": 2, "output": "apps/steam/assets/icon.png"},
        {"name": ["Lutris"], "palette": 2, "output": "apps/lutris/assets/icon.png"},
        {"name": ["Heroic"], "palette": 2, "output": "apps/heroic-games-launcher/assets/icon.png"},
        {"name": ["Prism Launcher", "(minecraft)"], "palette": 2, "output": "apps/prismlauncher/assets/icon.png"},
        {"name": ["Unigine Heaven"], "palette": 2, "output": "apps/unigine-benchmark/assets/heaven-icon.png"},
        {"name": ["Unigine Valley"], "palette": 2, "output": "apps/unigine-benchmark/assets/valley-icon.png"},
        {"name": ["Unigine Superposition"], "palette": 2, "output": "apps/unigine-benchmark/assets/superposition-icon.png"}
    ]

    for app in apps:
        generate_png_image(categories[app["palette"]]["start"],
                           categories[app["palette"]]["end"],
                           categories[app["palette"]]["icon"],
                           app["name"],
                           "HelveticaNeue.ttc",
                           50,
                           app["output"])


def main():
    # If no arguments are passed just generate all icons
    if len(sys.argv) == 1:
        gen_all_icons()
        return

    parser = argparse.ArgumentParser(description='Generate a PNG image with text and Material Icon.')
    parser.add_argument('--startcolor', default='#009eff',
                        help='Start color for the gradient background (e.g., "#FFFFFF")')
    parser.add_argument('--endcolor', default='#000a69', help='End color for the gradient background (e.g., "#000000")')
    parser.add_argument('--icon', default="e30c",
                        help='Code point of the Material Icon (e.g., "e30c" for desktop_windows)')
    parser.add_argument('--text', default=["Desktop"], nargs='+', help='Lines of text to add to the image')
    parser.add_argument('--font', default='HelveticaNeue.ttc', help='Path to the font file')
    parser.add_argument('--fontsize', type=int, default=40, help='Font size')
    # positional argument
    parser.add_argument('--output', default='output.png', help='Output file path')

    args = parser.parse_args()

    print(f"Generating image with start color {args.startcolor}, "
          f"end color {args.endcolor}, "
          f"icon {args.icon}, "
          f"text {args.text}, "
          f"font {args.font}, "
          f"font size {args.fontsize}, "
          f"and output path {args.output}")
    generate_png_image(args.startcolor, args.endcolor, args.icon, args.text, args.font, args.fontsize, args.output)


if __name__ == '__main__':
    main()
