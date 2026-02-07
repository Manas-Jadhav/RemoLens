# 📸 RemoLens: AI-Powered Inventory Manager

An intelligent Flutter application developed for electronic shopkeepers to manage and locate inventory using **Computer Vision** and **Vector Similarity Search**. Instead of searching by model numbers, users snap a photo of a remote to instantly retrieve its brand, price, and exact physical rack location.

## 🚀 Key Features

* **Visual Search:** Identify unknown remotes via AI feature extraction.
* **Auto-Cropping:** Powered by the **DETR (DEtection TRansformer)** model to isolate remotes from complex backgrounds.
* **Inventory Tracking:** Manage Brand, Category, Price (INR), and Rack/Shelf locations.
* **Cloud Backend:** Real-time data synchronization and image hosting via **Supabase**.
* **High-Speed Vector Search:** Millisecond-latency retrieval using **PostgreSQL (pgvector)** and Cosine Similarity.

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Database:** Supabase (PostgreSQL)
* **Vector Engine:** pgvector
* **On-Device ML:** TensorFlow Lite (`tflite_flutter`)
* **Computer Vision:** * **MobileNet V3:** 1280-dimensional feature embedding generation.
  * **DETR ResNet-50:** Cloud-based object detection for image segmentation.

## 🧠 Technical Architecture

1.  **Normalization:** App performs "Letterboxing" on images to maintain aspect ratio for the neural network.
2.  **Embedding Generation:** MobileNet V3 runs locally on the device to convert the image into a mathematical vector.
3.  **Similarity Search:** The vector is compared against the database using the **Cosine Distance** formula:  
    $$1 - (\text{stored\_vector} \cdot \text{query\_vector})$$
    (Calculated via the `<=>` operator in pgvector).
4.  **Result Retrieval:** The system returns matches above a specific confidence threshold (e.g., 85%).

## 📁 Repository Structure

lib/
├── services/             # TFLite Inference & Hugging Face API logic
├── widgets/              # Custom UI components (Image Picker, Info Rows)
├── pages/                # App screens (Home, Add, Search, Details)
├── main.dart             # Entry point & Supabase config
supabase/
└── schema.sql            # SQL Blueprint for Tables and RPC functions

⚙️ Installation & Setup
1. Environment Variables
Create a .env file in the project root:
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
HF_API_TOKEN=your_huggingface_token
HF_API_URL=[https://api-inference.huggingface.co/models/facebook/detr-resnet-50](https://api-inference.huggingface.co/models/facebook/detr-resnet-50)

2. Database Migration
Run the code in supabase/schema.sql inside your Supabase SQL Editor. This enables the vector extension and creates the match_remotes RPC function.

3. Flutter Setup
flutter pub get
flutter run

🧠 AI Credits
MobileNet V3 Large: Google via TensorFlow Hub.
Object Detection: Facebook via Hugging Face Inference API.

Developed by Manas Computer Science Student | Pune, India
