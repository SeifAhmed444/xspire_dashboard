import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xspire_dashboard/core/helper_functions/build_bar.dart';
import 'package:xspire_dashboard/core/widgets/custom_modal_progress_hub.dart';
import 'package:xspire_dashboard/features/add_product/presentation/manager/cubit/add_product_cubit.dart';
import 'package:xspire_dashboard/features/add_product/presentation/views/widgets/add_product_view_body.dart';

class AddProductViewBodyBlocBuilder extends StatelessWidget {
  const AddProductViewBodyBlocBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddProductCubit, AddProductState>(
      listener: (context, state) {
        if (state is AddProductSuccess) {
          showErrorBar(context, 'Product Added Successfully');
        }
          if (state is AddProductFailure) {
            showErrorBar(context, state.errMessage);
          }
      },
      builder: (context, state) {
        return CustomModalProgressHUD(
          
          inAsyncCall: state is AddProductLoading,
          child: const AddProductViewBody(),
        );
      },
    );
  }
}