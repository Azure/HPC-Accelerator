#!/home/linuxuser/anaconda3/bin/python3

import re
import json
import urllib.parse
from urllib.request import urlopen, Request
import sys
import argparse
import pandas as pd
from pandas import ExcelWriter
from pandas import ExcelFile
import pickle

from flask import Flask, render_template, request
app = Flask(__name__)


fileName = "region_vm_prices_pickle"
excel_file='./vm_storage_limits_costs.xlsx'

def format_data(data, data_type):
    if pd.isna(data):
       new_data = "n/a"
    elif data_type == "i":
       new_data = int(data)
    else: 
       new_data = data

    return new_data


def read_pickle_file():

    infile = open(fileName, 'rb')
    vm_price_d = pickle.load(infile)
    infile.close()

    return vm_price_d


def create_vm_dict(vm_name_l, vm_vendor_l, vm_processor_name_l, vm_vcpu_l, vm_hyperthreading_l, vm_avx512_l, vm_mem_GiB_l, vm_vcpu_freq_GHz_l, vm_vcpu_all_turbo_freq_GHz_l, vm_vcpu_max_turbo_freq_GHz_l, vm_gpu_type_l, vm_number_gpus_l, vm_size_gpu_mem_GiB_l, vm_nvlink_version_l, vm_infiniband_type_l, vm_infiniband_speed_Gbps_l, vm_tmp_storage_GiB_l,vm_max_num_data_disks_l,vm_max_cached_tmp_storage_throughput_MBps_l,vm_max_tmp_storage_read_throughput_MBps_l,vm_max_tmp_storage_write_throughput_MBps_l,vm_max_tmp_storage_iops_l,vm_max_uncached_disk_throughput_MBps_l,vm_max_uncached_disk_iops_l,vm_network_bw_Mbps_l,vm_cost_per_month_l):

    vm_d = {}
    for vm_i, sku_name in enumerate(vm_name_l):
        vm_d[sku_name] = {}
        vm_d[sku_name]["vendor"] = vm_vendor_l[vm_i]
        vm_d[sku_name]["processor_name"] = vm_processor_name_l[vm_i]
        vm_d[sku_name]["number_vcpus"] = int(vm_vcpu_l[vm_i])
        vm_d[sku_name]["hyperthreading"] = vm_hyperthreading_l[vm_i]
        vm_d[sku_name]["avx512"] = vm_avx512_l[vm_i]
        vm_d[sku_name]["size_mem_GiB"] = int(vm_mem_GiB_l[vm_i])
        vm_d[sku_name]["cpu_freq_GHz"] = vm_vcpu_freq_GHz_l[vm_i]
        vm_d[sku_name]["cpu_all_turbo_freq_GHz"] = vm_vcpu_all_turbo_freq_GHz_l[vm_i]
        vm_d[sku_name]["cpu_max_turbo_freq_GHz"] = vm_vcpu_max_turbo_freq_GHz_l[vm_i]
        vm_d[sku_name]["gpu_type"] = format_data(vm_gpu_type_l[vm_i], "s")
        vm_d[sku_name]["number_gpus"] = format_data(vm_number_gpus_l[vm_i], "i")
        vm_d[sku_name]["size_gpu_mem_GiB"] = vm_size_gpu_mem_GiB_l[vm_i]
        vm_d[sku_name]["infiniband_type"] = format_data(vm_infiniband_type_l[vm_i], "s")
        vm_d[sku_name]["infiniband_speed_Gbps"] = format_data(vm_infiniband_speed_Gbps_l[vm_i], "i")
        vm_d[sku_name]["size_local_ssd_GiB"] = format_data(vm_tmp_storage_GiB_l[vm_i], "i")
        vm_d[sku_name]["max_num_data_disks"] = vm_max_num_data_disks_l[vm_i]
        vm_d[sku_name]["max_local_ssd_throughput_MBps"] = vm_max_cached_tmp_storage_throughput_MBps_l[vm_i]
        vm_d[sku_name]["max_local_ssd_read_throughput_MBps"] = vm_max_tmp_storage_read_throughput_MBps_l[vm_i]
        vm_d[sku_name]["max_local_ssd_write_throughput_MBps"] = vm_max_tmp_storage_write_throughput_MBps_l[vm_i]
        vm_d[sku_name]["max_local_ssd_iops"] = vm_max_tmp_storage_iops_l[vm_i]
        vm_d[sku_name]["max_disk_throughput_MBps"] = vm_max_uncached_disk_throughput_MBps_l[vm_i]
        vm_d[sku_name]["max_disk_iops"] = vm_max_uncached_disk_iops_l[vm_i]
        vm_d[sku_name]["network_bw_Mbps"] = vm_network_bw_Mbps_l[vm_i]
        vm_d[sku_name]["cost_per_month"] = vm_cost_per_month_l[vm_i]

    return vm_d


def read_excel(excel_file):

   vm_limits_sheet = pd.read_excel(excel_file, skiprows=4, sheet_name='VM limits')
   vm_limits_sheet_dropna = vm_limits_sheet.dropna(how='all')

   vm_name_l = list(vm_limits_sheet_dropna['Size'])
   vm_vendor_l = list(vm_limits_sheet_dropna['Vendor'])
   vm_processor_name_l = list(vm_limits_sheet_dropna['Processor_name'])
   vm_vcpu_l = list(vm_limits_sheet_dropna['vCPU'])
   vm_hyperthreading_l = list(vm_limits_sheet_dropna['Hyperthreading'])
   vm_avx512_l = list(vm_limits_sheet_dropna['AVX512'])
   vm_mem_GiB_l = list(vm_limits_sheet_dropna['Memory: GiB'])
   vm_vcpu_freq_GHz_l = list(vm_limits_sheet_dropna['vCPU_freq_GHz'])
   vm_vcpu_all_turbo_freq_GHz_l = list(vm_limits_sheet_dropna['vCPU_all_turbo_freq_GHz'])
   vm_vcpu_max_turbo_freq_GHz_l = list(vm_limits_sheet_dropna['vCPU_max_turbo_freq_GHz'])
   vm_gpu_type_l = list(vm_limits_sheet_dropna['GPU_type'])
   vm_number_gpus_l = list(vm_limits_sheet_dropna['Number_GPUs'])
   vm_size_gpu_mem_GiB_l = list(vm_limits_sheet_dropna['Size_GPU_mem_GiB'])
   vm_nvlink_version_l = list(vm_limits_sheet_dropna['Nvlink_version'])
   vm_infiniband_type_l = list(vm_limits_sheet_dropna['Infiniband_type'])
   vm_infiniband_speed_Gbps_l = list(vm_limits_sheet_dropna['Infiniband_speed_Gbps'])
   vm_tmp_storage_GiB_l = list(vm_limits_sheet_dropna['Temp storage (SSD) GiB'])
   vm_max_num_data_disks_l = list(vm_limits_sheet_dropna['Max data disks'])
   vm_max_cached_tmp_storage_throughput_MBps_l = list(vm_limits_sheet_dropna['Max cached and temp storage throughput: MBps'])
   vm_max_tmp_storage_read_throughput_MBps_l = list(vm_limits_sheet_dropna['Max temp storage read throughput: MBps'])
   vm_max_tmp_storage_write_throughput_MBps_l = list(vm_limits_sheet_dropna['Max temp storage write throughput: MBps'])
   vm_max_tmp_storage_iops_l = list(vm_limits_sheet_dropna['Max cached and temp storage IOPS'])
   vm_max_uncached_disk_throughput_MBps_l = list(vm_limits_sheet_dropna['Max uncached disk throughput: MBps'])
   vm_max_uncached_disk_iops_l = list(vm_limits_sheet_dropna['Max uncached disk IOPS'])
   vm_network_bw_Mbps_l = list(vm_limits_sheet_dropna['Expected Network bandwidth (Mbps)'])
   vm_cost_per_month_l = list(vm_limits_sheet_dropna['cost/month PAYGO'])

   vm_d = create_vm_dict(vm_name_l, vm_vendor_l, vm_processor_name_l, vm_vcpu_l, vm_hyperthreading_l, vm_avx512_l, vm_mem_GiB_l, vm_vcpu_freq_GHz_l, vm_vcpu_all_turbo_freq_GHz_l, vm_vcpu_max_turbo_freq_GHz_l, vm_gpu_type_l, vm_number_gpus_l, vm_size_gpu_mem_GiB_l, vm_nvlink_version_l, vm_infiniband_type_l, vm_infiniband_speed_Gbps_l, vm_tmp_storage_GiB_l,vm_max_num_data_disks_l,vm_max_cached_tmp_storage_throughput_MBps_l,vm_max_tmp_storage_read_throughput_MBps_l,vm_max_tmp_storage_write_throughput_MBps_l,vm_max_tmp_storage_iops_l,vm_max_uncached_disk_throughput_MBps_l,vm_max_uncached_disk_iops_l,vm_network_bw_Mbps_l,vm_cost_per_month_l)

   return(vm_d)


def filter_str(str_selection, dict_field, vm_d):
    if str_selection:
       new_vm_d = {}
       for sku_name in vm_d:
           if not pd.isna(vm_d[sku_name][dict_field]) and (str_selection == vm_d[sku_name][dict_field] or vm_d[sku_name][dict_field] == "do_not_know"):
              new_vm_d[sku_name] = vm_d[sku_name]
       return new_vm_d
    else:
       return vm_d


def filter_str_list(str_list_selection_l, dict_field, vm_d):
    if str_list_selection_l:
       final_vm_d = {}
       for str_selection in str_list_selection_l:
           new_vm_d = filter_str(str_selection, dict_field, vm_d)
           final_vm_d.update(new_vm_d)
       return final_vm_d
    else:
       return vm_d


def filter_min_max_number(min_num_selection, max_num_selection, dict_field, vm_d):

    if min_num_selection and max_num_selection:
       new_vm_d = {}
       for sku_name in vm_d:
#           print(vm_d[sku_name][dict_field],float(min_num_selection),float(max_num_selection))
           if not vm_d[sku_name][dict_field] == "n/a" and (vm_d[sku_name][dict_field] == "do_not_know" or \
                 (vm_d[sku_name][dict_field] >= float(min_num_selection) and \
              vm_d[sku_name][dict_field] <= float(max_num_selection))):
              new_vm_d[sku_name] = vm_d[sku_name]
       return new_vm_d
    else:
        return vm_d


def filter_do_not_have_cost(vm_d):
  
    new_vm_d = {}
    for sku_name in vm_d:
        if not pd.isna(vm_d[sku_name]["cost_per_month"]):
           new_vm_d[sku_name] = vm_d[sku_name]

    return new_vm_d


def filter_region_vm_price(region, vm_d, region_vm_price_d):

    new_vm_d = {}
    if region in region_vm_price_d:
       for vm in vm_d:
           if vm in region_vm_price_d[region]:
              new_vm_d[vm] = vm_d[vm]
              new_vm_d[vm]["cost_per_hour"] = region_vm_price_d[region][vm]

    return new_vm_d


def mod_nan_values(value):
    if pd.isna(value):
       new_value = "N/A"
    else:
       new_value = value
    return new_value


def vm_report(vm_d):
     
    print("")
    print("{:<23} {:<50} {:<13} {:<14} {:<20} {:<17} {:<17} {:<8} {:<12}".format("VM Name", "CPU type", "Number vCPU's", "Mem Size (GiB)", "Local SSD Size (GiB)", "Network BW (Mbps)", "Infiniband (Gbps)", "GPU Type", "Cost/Month"))
    print("{:=<23} {:=<50} {:=<13} {:=<14} {:=<20} {:=<17} {:=<17} {:=<8} {:=<12}".format("=", "=", "=", "=", "=", "=", "=", "=", "="))
#    for sku_name in vm_d:
    for sku_name, value in sorted(vm_d.items(), key=lambda item: item[1]['cost_per_month']):
        cpu_type = "{} ({})".format(vm_d[sku_name]["vendor"], vm_d[sku_name]["processor_name"])
        number_vcpus = int(vm_d[sku_name]["number_vcpus"])
        size_mem_GiB = int(vm_d[sku_name]["size_mem_GiB"])
        if pd.isna(vm_d[sku_name]["size_local_ssd_GiB"]):
           size_local_ssd_GiB = "N/A"
        else:
           size_local_ssd_GiB = vm_d[sku_name]["size_local_ssd_GiB"]
        network_bw_Mbps = vm_d[sku_name]["network_bw_Mbps"]
        if pd.isna(vm_d[sku_name]["infiniband_type"]):
           infiniband_type_speed_Gbps = "N/A"
        elif vm_d[sku_name]["infiniband_type"] == "do_not_know":
           infiniband_type_speed_Gbps = "no_not_know"
        else:
           infiniband_type_speed_Gbps =  "{} ({})".format(vm_d[sku_name]["infiniband_type"], vm_d[sku_name]["infiniband_speed_Gbps"])
        if pd.isna(vm_d[sku_name]["gpu_type"]):
           gpu_type = "N/A"
        else:
           gpu_type = vm_d[sku_name]["gpu_type"]
        cost_per_month = vm_d[sku_name]["cost_per_month"]
        print("{:<23} {:<50} {:>13} {:>14} {:>20} {:>17} {:>17} {:>8} {:>12,.2f}".format(sku_name, cpu_type, number_vcpus, size_mem_GiB, size_local_ssd_GiB, network_bw_Mbps, infiniband_type_speed_Gbps, gpu_type, cost_per_month))


def extract_slider_values(val_str):

    val_str_l = val_str.split(";")
    return (val_str_l[0], val_str_l[1])


def main(region, processor_l, hyperthreading, avx512, cores_slider, cpu_mem_slider, cpu_freq_slider, infiniband_l, gpu_l, gpu_slider, ssd_slider, md_l):
    (cores_slider_from, cores_slider_to) = extract_slider_values(cores_slider)
    (cpu_mem_slider_from, cpu_mem_slider_to) = extract_slider_values(cpu_mem_slider)
    (cpu_freq_slider_from, cpu_freq_slider_to) = extract_slider_values(cpu_freq_slider)
    (gpu_slider_from, gpu_slider_to) = extract_slider_values(gpu_slider)
    (ssd_slider_from, ssd_slider_to) = extract_slider_values(ssd_slider)
    print(region, processor_l, hyperthreading, cores_slider_from, cores_slider_to, cpu_mem_slider_from,cpu_mem_slider_to, cpu_freq_slider_from, cpu_freq_slider_to, infiniband_l, gpu_l, gpu_slider_from, gpu_slider_to, ssd_slider_from, ssd_slider_to, md_l)

    vm_d = read_excel(excel_file)
    region_vm_price_d =  read_pickle_file()
    vm_d = filter_str_list(processor_l, "processor_name", vm_d)
    vm_d = filter_str(hyperthreading, "hyperthreading", vm_d)
    vm_d = filter_str(avx512, "avx512", vm_d)
    vm_d = filter_min_max_number(int(cores_slider_from), int(cores_slider_to), "number_vcpus", vm_d)
    vm_d = filter_min_max_number(int(cpu_mem_slider_from), int(cpu_mem_slider_to), "size_mem_GiB", vm_d)
    vm_d = filter_min_max_number(float(cpu_freq_slider_from), float(cpu_freq_slider_to), "cpu_all_turbo_freq_GHz", vm_d)
    vm_d = filter_str_list(gpu_l, "gpu_type", vm_d)
    vm_d = filter_min_max_number(int(gpu_slider_from), int(gpu_slider_to), "number_gpus", vm_d)
    vm_d = filter_min_max_number(int(ssd_slider_from), int(ssd_slider_to), "size_local_ssd_GiB", vm_d)
    vm_d = filter_str_list(infiniband_l, "infiniband_type", vm_d)

    vm_d = filter_region_vm_price(region, vm_d, region_vm_price_d)
    return (region, vm_d)


@app.route("/")
def index():
    return render_template('index.html')


@app.route('/report', methods=['POST'])
def handle_data():

    (region, vm_d) = main(request.form['region'], request.form.getlist('checkbox_processor'), request.form.get('radio_hyperthreading'), request.form.get('radio_avx512'), request.form['cores_slider'],  request.form['cpu_mem_slider'], request.form['cpu_freq_slider'], request.form.getlist('checkbox_ib'), request.form.getlist('checkbox_gpu'), request.form['gpu_slider'],  request.form['ssd_slider'], request.form.getlist('checkbox_md'))
    return render_template('table.html', region=region, result=vm_d)


#if __name__ == "__main__":
#    main()
