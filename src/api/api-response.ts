/// <reference path="../../typings/bundle.d.ts" />

import express = require('express');
export = APIResponse;

interface APIResponse extends express.Response {
	apiRender: (data: any) => void;
	apiError: (message: string) => void;
};
