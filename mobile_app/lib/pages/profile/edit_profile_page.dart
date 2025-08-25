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
        '编辑个人信息',
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
            '基本信息',
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
                '修改密码',
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
        labelText: '昵称 *',
        hintText: '请输入您的昵称',
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
          return '昵称不能为空';
        }
        if (value.trim().length < 2) {
          return '昵称至少需要2个字符';
        }
        return null;
      },
    );
  }

  Widget _buildUserProfileField() {
    return TextFormField(
      controller: _userProfileController,
      decoration: InputDecoration(
        labelText: '个人简介',
        hintText: '请输入您的个人简介，留空将使用默认简介',
        prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        counterText: '${_userProfileController.text.length}/100',
        helperText: '留空时将显示："这个人很懒，什么都没留下"',
        helperStyle: AppTextStyles.withColor(
          AppTextStyles.caption,
          Colors.grey,
        ),
      ),
      maxLines: 3,
      maxLength: 100,
      validator: (value) {
        if (value != null && value.length > 100) {
          return '个人简介不能超过100个字符';
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
        labelText: '新密码',
        hintText: '请输入新密码，留空则不修改',
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
            return '密码至少需要8个字符';
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
        labelText: '确认新密码',
        hintText: '请再次输入新密码',
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
            return '请确认新密码';
          }
          if (value != _passwordController.text) {
            return '两次输入的密码不一致';
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
                _hasChanges ? '保存修改' : '暂无修改',
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
          title: Text('确认离开', style: AppTextStyles.headingXS),
          content: Text('您有未保存的修改，确定要离开吗？', style: AppTextStyles.bodyMedium),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                '取消',
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
                '离开',
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
            userProfile: userProfile ?? "这个人很懒，什么都没留下",
          );
          await appState.updateUserInfo(updatedUser);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('个人信息更新成功'),
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
        throw Exception('更新失败');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '更新失败: ${e.toString().replaceFirst('Exception: ', '')}',
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