/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#include "fp8_rowwise_grouped_common.h"

std::vector<at::Tensor>
fp8_rowwise_grouped_256x128x128x128_32x32_2x2_8x32x1_8x32x1_1x32x1x8_8x8x1_1x1_interwave_v1(
    at::TensorList XQ,
    at::TensorList WQ,
    at::TensorList x_scale,
    at::TensorList w_scale,
    std::vector<at::Tensor> Y) {
  // A kernel that seems to work well on mid sized tensors.

  // Check if this input needs to be padded.
  bool pad = false;
  for (int i = 0; i < XQ.size(); i++) {
    int K = XQ[i].size(1);
    if (K % 128 != 0) {
      pad = true;
    }
  }

  // Dispatch based on whether padding is needed or not.
  if (pad) {
    using DeviceGemmInstance = DeviceGemmHelper<
        256,
        128,
        128,
        128,
        32,
        32,
        2,
        2,
        S<8, 32, 1>,
        S<8, 32, 1>,
        S<1, 32, 1, 8>,
        S<8, 8, 1>,
        1,
        1,
        ck::BlockGemmPipelineScheduler::Interwave,
        ck::BlockGemmPipelineVersion::v1,
        ck::tensor_operation::device::GemmSpecialization::KPadding>;
    // Run kernel instance.
    return f8f8bf16_rowwise_grouped_impl<DeviceGemmInstance>(
        XQ, WQ, x_scale, w_scale, Y);
  } else {
    using DeviceGemmInstance = DeviceGemmHelper<
        256,
        128,
        128,
        128,
        32,
        32,
        2,
        2,
        S<8, 32, 1>,
        S<8, 32, 1>,
        S<1, 32, 1, 8>,
        S<8, 8, 1>,
        1,
        1,
        ck::BlockGemmPipelineScheduler::Interwave,
        ck::BlockGemmPipelineVersion::v1,
        ck::tensor_operation::device::GemmSpecialization::Default>;
    // Run kernel instance.
    return f8f8bf16_rowwise_grouped_impl<DeviceGemmInstance>(
        XQ, WQ, x_scale, w_scale, Y);
  }
}
