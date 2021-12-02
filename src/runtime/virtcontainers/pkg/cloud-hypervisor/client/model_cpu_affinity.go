/*
Cloud Hypervisor API

Local HTTP based API for managing and inspecting a cloud-hypervisor virtual machine.

API version: 0.3.0
*/

// Code generated by OpenAPI Generator (https://openapi-generator.tech); DO NOT EDIT.

package openapi

import (
	"encoding/json"
)

// CpuAffinity struct for CpuAffinity
type CpuAffinity struct {
	Vcpu     *int32   `json:"vcpu,omitempty"`
	HostCpus *[]int32 `json:"host_cpus,omitempty"`
}

// NewCpuAffinity instantiates a new CpuAffinity object
// This constructor will assign default values to properties that have it defined,
// and makes sure properties required by API are set, but the set of arguments
// will change when the set of required properties is changed
func NewCpuAffinity() *CpuAffinity {
	this := CpuAffinity{}
	return &this
}

// NewCpuAffinityWithDefaults instantiates a new CpuAffinity object
// This constructor will only assign default values to properties that have it defined,
// but it doesn't guarantee that properties required by API are set
func NewCpuAffinityWithDefaults() *CpuAffinity {
	this := CpuAffinity{}
	return &this
}

// GetVcpu returns the Vcpu field value if set, zero value otherwise.
func (o *CpuAffinity) GetVcpu() int32 {
	if o == nil || o.Vcpu == nil {
		var ret int32
		return ret
	}
	return *o.Vcpu
}

// GetVcpuOk returns a tuple with the Vcpu field value if set, nil otherwise
// and a boolean to check if the value has been set.
func (o *CpuAffinity) GetVcpuOk() (*int32, bool) {
	if o == nil || o.Vcpu == nil {
		return nil, false
	}
	return o.Vcpu, true
}

// HasVcpu returns a boolean if a field has been set.
func (o *CpuAffinity) HasVcpu() bool {
	if o != nil && o.Vcpu != nil {
		return true
	}

	return false
}

// SetVcpu gets a reference to the given int32 and assigns it to the Vcpu field.
func (o *CpuAffinity) SetVcpu(v int32) {
	o.Vcpu = &v
}

// GetHostCpus returns the HostCpus field value if set, zero value otherwise.
func (o *CpuAffinity) GetHostCpus() []int32 {
	if o == nil || o.HostCpus == nil {
		var ret []int32
		return ret
	}
	return *o.HostCpus
}

// GetHostCpusOk returns a tuple with the HostCpus field value if set, nil otherwise
// and a boolean to check if the value has been set.
func (o *CpuAffinity) GetHostCpusOk() (*[]int32, bool) {
	if o == nil || o.HostCpus == nil {
		return nil, false
	}
	return o.HostCpus, true
}

// HasHostCpus returns a boolean if a field has been set.
func (o *CpuAffinity) HasHostCpus() bool {
	if o != nil && o.HostCpus != nil {
		return true
	}

	return false
}

// SetHostCpus gets a reference to the given []int32 and assigns it to the HostCpus field.
func (o *CpuAffinity) SetHostCpus(v []int32) {
	o.HostCpus = &v
}

func (o CpuAffinity) MarshalJSON() ([]byte, error) {
	toSerialize := map[string]interface{}{}
	if o.Vcpu != nil {
		toSerialize["vcpu"] = o.Vcpu
	}
	if o.HostCpus != nil {
		toSerialize["host_cpus"] = o.HostCpus
	}
	return json.Marshal(toSerialize)
}

type NullableCpuAffinity struct {
	value *CpuAffinity
	isSet bool
}

func (v NullableCpuAffinity) Get() *CpuAffinity {
	return v.value
}

func (v *NullableCpuAffinity) Set(val *CpuAffinity) {
	v.value = val
	v.isSet = true
}

func (v NullableCpuAffinity) IsSet() bool {
	return v.isSet
}

func (v *NullableCpuAffinity) Unset() {
	v.value = nil
	v.isSet = false
}

func NewNullableCpuAffinity(val *CpuAffinity) *NullableCpuAffinity {
	return &NullableCpuAffinity{value: val, isSet: true}
}

func (v NullableCpuAffinity) MarshalJSON() ([]byte, error) {
	return json.Marshal(v.value)
}

func (v *NullableCpuAffinity) UnmarshalJSON(src []byte) error {
	v.isSet = true
	return json.Unmarshal(src, &v.value)
}
