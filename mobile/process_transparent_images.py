import os
import cv2
import numpy as np
from PIL import Image

BASE_DIR = r"S:\Project\BuyerSellerManagementAPPSaas\mobile\assets\products"

def process_image(file_path):
    # Read image
    img = cv2.imread(file_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        return False

    if len(img.shape) == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)

    h, w = img.shape[:2]
    rgb = img[:, :, :3]
    hsv = cv2.cvtColor(rgb, cv2.COLOR_BGR2HSV)
    sat = hsv[:, :, 1]
    val = hsv[:, :, 2]

    # Sample corners (top-left, top-right, bottom-left, bottom-right)
    corner_samples = np.concatenate([
        rgb[0:15, 0:15].reshape(-1, 3),
        rgb[0:15, w-15:w].reshape(-1, 3),
        rgb[h-15:h, 0:15].reshape(-1, 3),
        rgb[h-15:h, w-15:w].reshape(-1, 3)
    ], axis=0)

    bg_color = np.median(corner_samples, axis=0)
    color_diff = np.sqrt(np.sum((rgb.astype(np.float32) - bg_color)**2, axis=2))

    # Mask background based on corner color similarity OR high lightness & low saturation
    is_corner_match = color_diff < 38
    is_white_studio = (sat < 35) & (val > 215)
    raw_bg = is_corner_match | is_white_studio

    # Flood fill mask from all 4 borders to avoid cutting internal light spots
    bg_flood = np.zeros((h + 2, w + 2), dtype=np.uint8)
    fg_mask = np.ones((h, w), dtype=np.uint8) * 255

    # Check border points
    mask_to_flood = raw_bg.astype(np.uint8) * 255
    # Find connected components from edges
    num_labels, labels, stats, centroids = cv2.connectedComponentsWithStats(mask_to_flood, connectivity=4)

    # Edge connected labels
    edge_labels = set()
    edge_labels.update(labels[0, :])
    edge_labels.update(labels[h-1, :])
    edge_labels.update(labels[:, 0])
    edge_labels.update(labels[:, w-1])

    is_connected_bg = np.isin(labels, list(edge_labels)) & (labels != 0)

    # Invert so 0 = bg, 255 = fg
    alpha = np.where(is_connected_bg, 0, 255).astype(np.uint8)

    # If the product had a natural photo background and corner flood fill didn't clear enough:
    # also apply a soft circular vignette/mask around the subject
    fg_ratio = np.sum(alpha > 0) / (h * w)
    if fg_ratio > 0.85:
        # Create circular vignette mask
        Y, X = np.ogrid[:h, :w]
        dist_from_center = np.sqrt((X - w/2)**2 + (Y - h/2)**2)
        radius = min(h, w) * 0.46
        circ_mask = np.clip((radius - dist_from_center) / 10.0, 0, 1)
        alpha = (alpha * circ_mask).astype(np.uint8)

    # Anti-alias / smooth edges
    alpha = cv2.GaussianBlur(alpha, (3, 3), 0)

    # Construct RGBA output
    rgba = cv2.cvtColor(rgb, cv2.COLOR_BGR2BGRA)
    rgba[:, :, 3] = alpha

    # Save as PNG
    cv2.imwrite(file_path, rgba)
    return True

total = 0
processed = 0
for root, dirs, files in os.walk(BASE_DIR):
    for f in files:
        if f.endswith('.png') and not f.endswith('_transparent.png') and not f.endswith('_cv.png'):
            total += 1
            p = os.path.join(root, f)
            if process_image(p):
                processed += 1

print(f"Processed transparent cutouts for {processed}/{total} images.")

