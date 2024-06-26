#!/usr/bin/env bats
# Copyright (c) 2023 Intel Corporation
# Copyright (c) 2023 IBM Corporation
#
# SPDX-License-Identifier: Apache-2.0
#

load "${BATS_TEST_DIRNAME}/lib.sh"
load "${BATS_TEST_DIRNAME}/confidential_common.sh"

setup() {
    confidential_setup || skip "Test not supported for ${KATA_HYPERVISOR}."
    setup_common 
    unencrypted_image_1="quay.io/sjenning/nginx:1.15-alpine"
    unencrypted_image_2="quay.io/prometheus/busybox:latest"
}

@test "Test we can pull an unencrypted image outside the guest with runc and then inside the guest successfully" {
    [[ " ${SUPPORTED_NON_TEE_HYPERVISORS} " =~ " ${KATA_HYPERVISOR} " ]] && skip "Test not supported for ${KATA_HYPERVISOR}."
    # 1. Create one runc pod with the $unencrypted_image_1 image
    # We want to have one runc pod, so we pass a fake runtimeclass "runc" and then delete the runtimeClassName,
    # because the runtimeclass is not optional in new_pod_config function.
    runc_pod_config="$(new_pod_config "$unencrypted_image_1" "runc")"
    sed -i '/runtimeClassName:/d' $runc_pod_config
    set_node "$runc_pod_config" "$node"
    set_container_command "$runc_pod_config" "0" "sleep" "30"

    # For debug sake
    echo "Pod $runc_pod_config file:"
    cat $runc_pod_config

    k8s_create_pod "$runc_pod_config"

    echo "Runc pod test-e2e is running"
    kubectl delete -f "$runc_pod_config"

    # 2. Create one kata pod with the $unencrypted_image_1 image and nydus annotation
    kata_pod_with_nydus_config="$(new_pod_config "$unencrypted_image_1" "kata-${KATA_HYPERVISOR}")"
    set_node "$kata_pod_with_nydus_config" "$node"
    set_container_command "$kata_pod_with_nydus_config" "0" "sleep" "30"

    # Set annotation to pull image in guest
    set_metadata_annotation "$kata_pod_with_nydus_config" \
        "io.containerd.cri.runtime-handler" \
        "kata-${KATA_HYPERVISOR}"

    # For debug sake
    echo "Pod $kata_pod_with_nydus_config file:"
    cat $kata_pod_with_nydus_config

    k8s_create_pod "$kata_pod_with_nydus_config"
    echo "Kata pod test-e2e with nydus annotation is running"

    echo "Checking the image was pulled in the guest"
    sandbox_id=$(get_node_kata_sandbox_id $node)
    echo "sandbox_id is: $sandbox_id"
    # With annotation for nydus, only rootfs for pause container can be found on host
    assert_rootfs_count "$node" "$sandbox_id" "1"
}

@test "Test we can pull an unencrypted image inside the guest twice in a row and then outside the guest successfully" {
    [[ " ${SUPPORTED_NON_TEE_HYPERVISORS} " =~ " ${KATA_HYPERVISOR} " ]] && skip "Test not supported for ${KATA_HYPERVISOR}."
    skip "Skip this test until we use containerd 2.0 with 'image pull per runtime class' feature: https://github.com/containerd/containerd/issues/9377"
    # 1. Create one kata pod with the $unencrypted_image_1 image and nydus annotation twice
    kata_pod_with_nydus_config="$(new_pod_config "$unencrypted_image_1" "kata-${KATA_HYPERVISOR}")"
    set_node "$kata_pod_with_nydus_config" "$node"
    set_container_command "$kata_pod_with_nydus_config" "0" "sleep" "30"

    # Set annotation to pull image in guest
    set_metadata_annotation "$kata_pod_with_nydus_config" \
        "io.containerd.cri.runtime-handler" \
        "kata-${KATA_HYPERVISOR}"

    # For debug sake
    echo "Pod $kata_pod_with_nydus_config file:"
    cat $kata_pod_with_nydus_config

    k8s_create_pod "$kata_pod_with_nydus_config"
    
    echo "Kata pod test-e2e with nydus annotation is running"
    echo "Checking the image was pulled in the guest"

    sandbox_id=$(get_node_kata_sandbox_id $node)
    echo "sandbox_id is: $sandbox_id"
    # With annotation for nydus, only rootfs for pause container can be found on host
    assert_rootfs_count "$node" "$sandbox_id" "1"

    kubectl delete -f $kata_pod_with_nydus_config

    # 2. Create one kata pod with the $unencrypted_image_1 image and without nydus annotation
    kata_pod_without_nydus_config="$(new_pod_config "$unencrypted_image_1" "kata-${KATA_HYPERVISOR}")"
    set_node "$kata_pod_without_nydus_config" "$node"
    set_container_command "$kata_pod_without_nydus_config" "0" "sleep" "30"

    # For debug sake
    echo "Pod $kata_pod_without_nydus_config file:"
    cat $kata_pod_without_nydus_config

    k8s_create_pod "$kata_pod_without_nydus_config"

    echo "Kata pod test-e2e without nydus annotation is running"
    echo "Check the image was not pulled in the guest"
    sandbox_id=$(get_node_kata_sandbox_id $node)
    echo "sandbox_id is: $sandbox_id"

    # The assert_rootfs_count will be FAIL.
    # The expect count of rootfs in host is "2" but the found count of rootfs in host is "1"
    # As the the first time we pull the $unencrypted_image_1 image via nydus-snapshotter in the guest
    # for all subsequent pulls still use nydus-snapshotter in the guest
    # More details: https://github.com/kata-containers/kata-containers/issues/8337
    # The test case will be PASS after we use containerd 2.0 with 'image pull per runtime class' feature:
    # https://github.com/containerd/containerd/issues/9377
    assert_rootfs_count "$node" "$sandbox_id" "2"
}

@test "Test we can pull an other unencrypted image outside the guest and then inside the guest successfully" {
    [[ " ${SUPPORTED_NON_TEE_HYPERVISORS} " =~ " ${KATA_HYPERVISOR} " ]] && skip "Test not supported for ${KATA_HYPERVISOR}."
    skip "Skip this test until we use containerd 2.0 with 'image pull per runtime class' feature: https://github.com/containerd/containerd/issues/9377"
    # 1. Create one kata pod with the $unencrypted_image_2 image and without nydus annotation
    kata_pod_without_nydus_config="$(new_pod_config "$unencrypted_image_2" "kata-${KATA_HYPERVISOR}")"
    set_node "$kata_pod_without_nydus_config" "$node"
    set_container_command "$kata_pod_without_nydus_config" "0" "sleep" "30"

    # For debug sake
    echo "Pod $kata_pod_without_nydus_config file:"
    cat $kata_pod_without_nydus_config

    k8s_create_pod "$kata_pod_without_nydus_config"
    
    echo "Kata pod test-e2e without nydus annotation is running"
    echo "Checking the image was pulled in the host"

    sandbox_id=$(get_node_kata_sandbox_id $node)
    echo "sandbox_id is: $sandbox_id"
    # Without annotation for nydus, both rootfs for pause and the test container can be found on host
    assert_rootfs_count "$node" "$sandbox_id" "2"

    kubectl delete -f $kata_pod_without_nydus_config

    # 2. Create one kata pod with the $unencrypted_image_2 image and with nydus annotation
    kata_pod_with_nydus_config="$(new_pod_config "$unencrypted_image_2" "kata-${KATA_HYPERVISOR}")"
    set_node "$kata_pod_with_nydus_config" "$node"
    set_container_command "$kata_pod_with_nydus_config" "0" "sleep" "30"

    # Set annotation to pull image in guest
    set_metadata_annotation "$kata_pod_with_nydus_config" \
        "io.containerd.cri.runtime-handler" \
        "kata-${KATA_HYPERVISOR}"

    # For debug sake
    echo "Pod $kata_pod_with_nydus_config file:"
    cat $kata_pod_with_nydus_config

    k8s_create_pod "$kata_pod_with_nydus_config"
    
    echo "Kata pod test-e2e with nydus annotation is running"
    echo "Checking the image was pulled in the guest"
    sandbox_id=$(get_node_kata_sandbox_id $node)
    echo "sandbox_id is: $sandbox_id"

    # The assert_rootfs_count will be FAIL.
    # The expect count of rootfs in host is "1" but the found count of rootfs in host is "2"
    # As the the first time we pull the $unencrypted_image_2 image via overlayfs-snapshotter in host
    # for all subsequent pulls still use overlayfs-snapshotter in host.
    # More details: https://github.com/kata-containers/kata-containers/issues/8337
    # The test case will be PASS after we use containerd 2.0 with 'image pull per runtime class' feature:
    # https://github.com/containerd/containerd/issues/9377
    assert_rootfs_count "$node" "$sandbox_id" "1"
}

teardown() {
    check_hypervisor_for_confidential_tests ${KATA_HYPERVISOR} || skip "Test not supported for ${KATA_HYPERVISOR}."
    kubectl describe pod "$pod_name"
    k8s_delete_all_pods_if_any_exists || true
}
