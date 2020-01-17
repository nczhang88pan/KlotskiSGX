#!/usr/bin/env python
# coding=utf-8
import os
import subprocess
import sys

GBK = 'gbk'
UTF8 = 'utf-8'
current_encoding = GBK

def runNbench(randomPageSwap, cacheNum):
    #make
    #1. make clean
    print("make clean")
    output = subprocess.check_output("make clean", shell=True)
    makeNbenchProgramCMD = "make SGX_MODE=HW SGX_DEBUG=1 CACHENUM=" + str(cacheNum)

    if randomPageSwap==False:
        makeNbenchProgramCMD = makeNbenchProgramCMD + " RPS=OFF"
        outputFile = "./resultDir/nbench/Result.withORAM." + str(cacheNum)
    else:
        makeNbenchProgramCMD = makeNbenchProgramCMD + " RPS=ON"
        outputFile = "./resultDir/nbench/Result.withORAM.RPS." + str(cacheNum)

    makeNbenchProgramCMD = makeNbenchProgramCMD + " TARGET=nbench"

    #2. make
    print(makeNbenchProgramCMD)
    output = subprocess.check_output(makeNbenchProgramCMD, shell=True)
    #3. run program nbench
    with open(outputFile, "w") as fp:
        cmd = "./app nbench"
        print("exectuing: "+ cmd + "; saving to" + outputFile)
        exec_program(cmd, fp)
    	#output = subprocess.check_output(cmd, shell=True)
        #fp.write(output)

def exec_program(cmd, output_fp):
	current_encoding = GBK

	popen = subprocess.Popen( cmd.split(" "),
                         stdout = subprocess.PIPE,
                         stderr = subprocess.PIPE,
                         bufsize=1)

	while popen.poll() is None:
    		r = popen.stdout.readline().decode(current_encoding)
		output_fp.write(r)

	if popen.poll() != 0: 
    		err = popen.stderr.read().decode(current_encoding)
    		sys.stdout.write(err)             

def processingNbench():
    cacheNumSet = [2,4,8]
    print("processingNbench")
    randomPageSwap= False 
    for cacheNum in cacheNumSet:
        runNbench(randomPageSwap,cacheNum)

def runDjpeg(randomPageSwap, cacheSize):
    #make
    #1. make clean
    print("make clean")
    output = subprocess.check_output("make clean", shell=True)
    makeDJPEGProgramCMD = "make SGX_MODE=HW SGX_DEBUG=1 CACHENUM=" + str(cacheSize)

    if randomPageSwap==False:
        makeDJPEGProgramCMD = makeDJPEGProgramCMD + " RPS=OFF"
        outputFile = "./resultDir/djpeg/Result.withORAM."+ str(cacheSize)
    else:
        makeDJPEGProgramCMD = makeDJPEGProgramCMD + " RPS=ON"
        outputFile = "./resultDir/djpeg/Result.withORAM.RPS."+ str(cacheSize)

    makeDJPEGProgramCMD = makeDJPEGProgramCMD + " TARGET=DJPEG"

    #2. make
    print(makeDJPEGProgramCMD)
    print("saving to:" + outputFile)
    output = subprocess.check_output(makeDJPEGProgramCMD, shell=True)
    
    #3. run program nbench
    input_jpegs = "/home/root/klotski/libjpeg/testCase/inputDir/jpg/download"
    output_ppms = "/home/root/klotski/libjpeg/testCase/outputDir/bmp/download"

    #output = subprocess.check_output("rm /home/root/klotski/libjpeg/testCase/outputDir/bmp/*", shell=True)
    with open(outputFile, "w") as fp:
        cmd = "./app djpeg " + input_jpegs + " " + output_ppms
        print("exectuing: "+ cmd + ", saving to:" + outputFile)
        exec_program(cmd, fp)
        
    	#output = subprocess.check_output(cmd, shell=True, stdout=fp)
        #fp.write(output)

def runCjpeg(randomPageSwap, cacheSize):
    #make
    #1. make clean
    print("make clean")
    output = subprocess.check_output("make clean", shell=True)
    makeCJPEGProgramCMD = "make SGX_MODE=HW SGX_DEBUG=1 CACHENUM=" + str(cacheSize)
    if randomPageSwap==False:
        makeCJPEGProgramCMD = makeCJPEGProgramCMD + " RPS=OFF"
        outputFile = "./resultDir/cjpeg/Result.withORAM."+ str(cacheSize)
    else:
        makeCJPEGProgramCMD = makeCJPEGProgramCMD + " RPS=ON"
        outputFile = "./resultDir/cjpeg/Result.withORAM.RPS." + str(cacheSize)

    makeCJPEGProgramCMD = makeCJPEGProgramCMD + " TARGET=CJPEG"

    #2. make
    print(makeCJPEGProgramCMD)
    print("saving to:" + outputFile)
    output = subprocess.check_output(makeCJPEGProgramCMD, shell=True)
    #3. run program nbench
    input_ppms = "/home/root/klotski/libjpeg/testCase/inputDir/ppm/download"
    output_jpgs = "/home/root/klotski/libjpeg/testCase/outputDir/jpg/download"
    #output = subprocess.check_output("rm /home/root/klotski/libjpeg/testCase/outputDir/jpg/*", shell=True)
    with open(outputFile, "w") as fp:
        cmd = "./app cjpeg " + input_ppms + " " + output_jpgs
        print("exectuing: "+ cmd + ", saving to:" + outputFile)
        exec_program(cmd, fp)
    	#output = subprocess.check_output(cmd, shell=True, stdout=fp)
        #fp.write(output)

def processingJpeg():
    cacheNumSet = [2,4,8,16,32]
    print("processingDjpeg")

    randomPageSwap = False 
    for cacheNum in cacheNumSet:
        runDjpeg(randomPageSwap, cacheNum)
        runCjpeg(randomPageSwap, cacheNum)

    randomPageSwap = True
    for cacheNum in cacheNumSet:
        runDjpeg(randomPageSwap, cacheNum)
        runCjpeg(randomPageSwap, cacheNum)


def runTLS(randomPageSwap, cacheSize):
    makeTLSProgramCMD = "make SGX_MODE=HW SGX_DEBUG=1 CACHENUM=" + str(cacheSize)
    if randomPageSwap==True:
        makeTLSProgramCMD = "make SGX_MODE=HW SGX_DEBUG=1 CACHENUM=" + str(cacheSize) + " RPS=ON"
    else:
        makeTLSProgramCMD = "make SGX_MODE=HW SGX_DEBUG=1 CACHENUM=" + str(cacheSize) + " RPS=OFF"

    makeTLSProgramCMD = makeTLSProgramCMD + " TARGET=HTTPS"

    #2. make
    print("------------set cache =" + str(cacheSize) + "--------------")
    print("make clean")
    print(makeTLSProgramCMD)
    #3. run program nbench
    cmd = "./app https"
    print(cmd)
    print("ab -n50 -f TLS1.1  https://127.0.0.1:4433/")

def processingTLS():
    cacheNumSet = [2,4,8,16,32]
    print("processingDjpeg")
    randomPageSwap = True
    for cacheNum in cacheNumSet:
        runTLS(randomPageSwap, cacheNum)

    randomPageSwap = False 
    for cacheNum in cacheNumSet:
        runTLS(randomPageSwap, cacheNum)

def main():
    #processingNbench()
    processingJpeg()
    processingTLS()

if __name__=="__main__":
    main()
