import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/core/state/services/supabase_storage_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SharedImagePicker extends StatefulWidget {
  final String?
      initialImageUrl; // Dùng cho màn hình Sửa (truyền Signed URL vào)
  final String folderPath; // Thư mục lưu trên Supabase (vd: 'products')
  final Function(String imagePath) onImageUploaded; // Callback trả về path tĩnh

  const SharedImagePicker({
    super.key,
    this.initialImageUrl,
    required this.folderPath,
    required this.onImageUploaded,
  });

  @override
  State<SharedImagePicker> createState() => _SharedImagePickerState();
}

class _SharedImagePickerState extends State<SharedImagePicker> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  File? _localFile;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Nén nhẹ ảnh để tối ưu
    );

    if (pickedFile != null) {
      setState(() {
        _localFile = File(pickedFile.path);
        _isUploading = true;
      });

      // Bắt đầu upload
      final String? uploadedPath = await _storageService.uploadImage(
        imageFile: _localFile!,
        folderPath: widget.folderPath,
      );

      setState(() {
        _isUploading = false;
      });

      if (uploadedPath != null) {
        // Trả path về cho Form cha
        widget.onImageUploaded(uploadedPath);
      } else {
        TSnackbarsWidget.error(
          title: 'Lỗi',
          message: 'Upload ảnh thất bại. Vui lòng thử lại!',
        );
        setState(() {
          _localFile = null; // Reset nếu lỗi
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _pickAndUploadImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isUploading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Nếu vừa chọn ảnh mới thì ưu tiên show ảnh mới từ Local
    if (_localFile != null) {
      return Image.file(_localFile!, fit: BoxFit.cover);
    }

    // Nếu là màn Edit, hiển thị ảnh cũ từ Backend (Signed URL)
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.initialImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) =>
            const Icon(Icons.error, color: Colors.red),
      );
    }

    // Trạng thái rỗng (Chưa có ảnh)
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: Colors.grey, size: 32),
        SizedBox(height: 8),
        Text('Thêm ảnh', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
