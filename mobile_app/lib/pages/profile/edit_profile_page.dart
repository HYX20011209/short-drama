import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/app_state.dart';
import '../../services/user_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_text_styles.dart';

/// 用户信息编辑页面
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 表单控制器
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userNameController;
  late TextEditingController _userProfileController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  // 状态管理
  bool _isLoading = false;
  bool _hasChanges = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initControllers();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  void _initControllers() {
    final currentUser = context.read<AppState>().currentUser;
    _userNameController = TextEditingController(
      text: currentUser?.userName ?? '',
    );
    _userProfileController = TextEditingController(
      text: currentUser?.userProfile ?? '',
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // 监听文本变化
    _userNameController.addListener(_onTextChanged);
    _userProfileController.addListener(_onTextChanged);
    _passwordController.addListener(_onTextChanged);
    _confirmPasswordController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final currentUser = context.read<AppState>().currentUser;
    final hasChanges =
        _userNameController.text != (currentUser?.userName ?? '') ||
            _userProfileController.text != (currentUser?.userProfile ?? '') ||
            _passwordController.text.isNotEmpty ||
            _confirmPasswordController.text.isNotEmpty;

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _userNameController.dispose();
    _userProfileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.light
              ? AppColors.backgroundGradient
              : AppColors.darkBackgroundGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppDimensions.spacingLG),
                  children: [
                    const SizedBox(height: AppDimensions.spacingLG),

                    // 基本信息编辑卡片
                    _buildBasicInfoCard(),

                    const SizedBox(height: AppDimensions.spacingXL),

                    // 密码修改卡片
                    _buildPasswordCard(),

                    const SizedBox(height: AppDimensions.spacing3XL),

                    // 保存按钮
                    _buildSaveButton(),

                    const SizedBox(height: AppDimensions.spacingXL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary.withOpacity(0.1), Colors.transparent],
          ),
        ),
      ),
      title: Text(
        'Edit Profile',
        style: AppTextStyles.withPrimary(AppTextStyles.headingSM),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: _handleBackPress,
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.primary,
          size: AppDimensions.iconSizeMedium,
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: AppTextStyles.headingXS.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXL),

          // 用户昵称输入框
          _buildUserNameField(),

          const SizedBox(height: AppDimensions.spacingLG),

          // 个人简介输入框
          _buildUserProfileField(),
        ],
      ),
    );
  }

  Widget _buildPasswordCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXL),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        boxShadow: AppShadows.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Change Password',
                style: AppTextStyles.headingXS.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSM),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXL),

          // 新密码输入框
          _buildPasswordField(),

          const SizedBox(height: AppDimensions.spacingLG),

          // 确认密码输入框
          _buildConfirmPasswordField(),
        ],
      ),
    );
  }

  Widget _buildUserNameField() {
    return TextFormField(
      controller: _userNameController,
      decoration: InputDecoration(
        labelText: 'Nickname *',
        hintText: 'Enter your nickname',
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: AppColors.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        counterText: '${_userNameController.text.length}/20',
      ),
      maxLength: 20,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nickname cannot be empty';
        }
        if (value.trim().length < 2) {
          return 'Nickname must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildUserProfileField() {
    return TextFormField(
      controller: _userProfileController,
      decoration: InputDecoration(
        labelText: 'Bio',
        hintText: 'Enter your bio, leave empty for default',
        prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        counterText: '${_userProfileController.text.length}/100',
        helperText: 'Default: "No bio available"',
        helperStyle: AppTextStyles.withColor(
          AppTextStyles.caption,
          Colors.grey,
        ),
      ),
      maxLines: 3,
      maxLength: 100,
      validator: (value) {
        if (value != null && value.length > 100) {
          return 'Bio cannot exceed 100 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'New Password',
        hintText: 'Enter new password, leave empty to keep current',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          icon: Icon(
            _isPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppColors.primary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        // 如果输入了密码，则验证长度
        if (value != null && value.isNotEmpty) {
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Confirm New Password',
        hintText: 'Enter new password again',
        prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primary),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
          icon: Icon(
            _isConfirmPasswordVisible
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppColors.primary,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      validator: (value) {
        // 如果输入了新密码，则确认密码也必须输入且一致
        if (_passwordController.text.isNotEmpty) {
          if (value == null || value.isEmpty) {
            return 'Please confirm new password';
          }
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        boxShadow: _hasChanges ? AppShadows.primaryGlow(opacity: 0.3) : null,
      ),
      child: ElevatedButton(
        onPressed: _hasChanges && !_isLoading ? _handleSave : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _hasChanges
              ? AppColors.primary
              : AppColors.primary.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: _hasChanges ? 4 : 0,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingLG,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _hasChanges ? 'Save Changes' : 'No Changes',
                style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
              ),
      ),
    );
  }

  // ==================== 事件处理 ====================

  void _handleBackPress() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          title: Text('Confirm Exit', style: AppTextStyles.headingXS),
          content: Text('You have unsaved changes. Are you sure you want to leave?', style: AppTextStyles.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.withColor(
                  AppTextStyles.buttonMedium,
                  AppColors.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回上级页面
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
              child: Text(
                'Leave',
                style: AppTextStyles.withColor(
                  AppTextStyles.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 准备请求参数
      String? userName = _userNameController.text.trim().isEmpty
          ? null
          : _userNameController.text.trim();
      String? userProfile = _userProfileController.text.trim().isEmpty
          ? null
          : _userProfileController.text.trim();
      String? userPassword = _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim();

      final success = await UserService.updateUserProfile(
        userName: userName,
        userProfile: userProfile,
        userPassword: userPassword,
      );

      if (success) {
        // 更新本地用户状态（不包括密码）
        final appState = context.read<AppState>();
        if (appState.currentUser != null) {
          final updatedUser = appState.currentUser!.copyWith(
            userName: userName,
            userProfile: userProfile ?? "No bio available",
          );
          await appState.updateUserInfo(updatedUser);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
              ),
            ),
          );
          Navigator.pop(context, true); // 返回并传递成功标志
        }
      } else {
        throw Exception('Update failed');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Update failed: ${e.toString().replaceFirst('Exception: ', '')}',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}