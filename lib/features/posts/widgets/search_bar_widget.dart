import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_strings.dart';
import '../../posts/providers/posts_provider.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PostsProvider>();
    return Container(
      color: AppColors.basalt800,
      padding: const EdgeInsets.fromLTRB(
          AppDimens.lg, AppDimens.sm, AppDimens.lg, AppDimens.md),
      child: Row(children: [
        // ── حقل البحث ────────────────────────────────────────────────
        Expanded(
          child: SizedBox(
            height: 42,
            child: TextField(
              onChanged: provider.onSearchChanged,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Cairo',
                  fontSize: AppDimens.fontSm, color: AppColors.basalt900),
              decoration: InputDecoration(
                hintText:   AppStrings.searchHint,
                hintStyle:  const TextStyle(color: AppColors.basalt400,
                    fontFamily: 'Cairo', fontSize: AppDimens.fontSm),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.basalt400, size: 20),
                filled:     true,
                fillColor:  AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.sm, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimens.sm),

        // ── فلتر المنطقة ─────────────────────────────────────────────
        Consumer<PostsProvider>(
          builder: (context, prov, _) => Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm),
            decoration: BoxDecoration(
              color:        AppColors.basalt700,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:     prov.selectedRegion,
                dropdownColor: AppColors.basalt800,
                style:     const TextStyle(fontFamily: 'Cairo',
                    fontSize: AppDimens.fontXs, color: AppColors.wheat300),
                icon:      const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.wheat300, size: 18),
                items: AppStrings.regions.map((r) =>
                  DropdownMenuItem(value: r,
                    child: Text(r, style: const TextStyle(
                        fontFamily: 'Cairo', fontSize: AppDimens.fontXs,
                        color: AppColors.wheat300)))).toList(),
                onChanged: (r) { if (r != null) prov.setRegion(r); },
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
